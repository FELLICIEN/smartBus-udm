import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BusPage extends StatelessWidget {
  const BusPage({super.key});

  /// 🚌 STREAM BUSES
  Stream<QuerySnapshot> getBuses() {
    return FirebaseFirestore.instance.collection('buses').snapshots();
  }

  SnackBar buildSnackBar(String message) {
    return SnackBar(content: Text(message));
  }

  /// 🎨 COLOR STATUS
  Color getColor(String status) {
    switch (status.toLowerCase()) {
      case "disponible":
        return Colors.green;
      case "en service":
        return Colors.orange;
      case "en panne":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// ⏰ FORMAT TIME
  String formatTime(dynamic time) {
    if (time == null) return "—";

    if (time is Timestamp) {
      return DateFormat('HH:mm').format(time.toDate());
    }

    return time.toString();
  }

  /// 🔥 GET HEURE FROM PASSAGES
  Future<String> getHeure(String busId) async {
    final q = await FirebaseFirestore.instance
        .collection('passages')
        .where('busId', isEqualTo: busId)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return "—";

    final data = q.docs.first.data();
    return formatTime(data['heurePrevue']);
  }

  /// 🗑️ DELETE BUS
  Future<void> deleteBus(String id) async {
    await FirebaseFirestore.instance.collection('buses').doc(id).delete();
  }

  /// ✏️ UPDATE BUS (AVEC HEURE)
  Future<void> updateBus(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) async {
    TextEditingController nomController =
        TextEditingController(text: data['nom']);

    TextEditingController chauffeurController =
        TextEditingController(text: data['chauffeur']);

    TextEditingController heureController =
        TextEditingController(text: data['heure'] ?? "");

    const List<String> statuses = [
      "disponible",
      "en service",
      "en panne"
    ];

    String status = data['status'] ?? "disponible";

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Modifier le bus"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// 🚌 NOM
                    TextField(
                      controller: nomController,
                      decoration: const InputDecoration(
                        labelText: "Nom du bus",
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 👨‍✈️ CHAUFFEUR
                    TextField(
                      controller: chauffeurController,
                      decoration: const InputDecoration(
                        labelText: "Chauffeur",
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// ⏰ HEURE (AJOUTÉ)
                    TextField(
                      controller: heureController,
                      decoration: const InputDecoration(
                        labelText: "Heure (ex: 14:30)",
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 📌 STATUS
                    DropdownButtonFormField<String>(
                      initialValue: statuses.contains(status)
                          ? status
                          : statuses[0],
                      items: statuses.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            s[0].toUpperCase() + s.substring(1),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          status = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Status",
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    /// UPDATE BUS
                    await FirebaseFirestore.instance
                        .collection('buses')
                        .doc(id)
                        .update({
                      'nom': nomController.text,
                      'chauffeur': chauffeurController.text,
                      'status': status,
                      'heure': heureController.text,
                    });

                    /// OPTION : update passage aussi
                    final passage = await FirebaseFirestore.instance
                        .collection('passages')
                        .where('busId', isEqualTo: id)
                        .limit(1)
                        .get();

                    if (passage.docs.isNotEmpty) {
                      await passage.docs.first.reference.update({
                        'heurePrevue': heureController.text,
                      });
                    }

                    Navigator.pop(context);
                
                    ScaffoldMessenger.of(context).showSnackBar(
                      buildSnackBar("Bus mis à jour avec succès ✅"),
                    );
                  },
                  child: const Text("Modifier"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: StreamBuilder<QuerySnapshot>(
        stream: getBuses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final buses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final data =
                  buses[index].data() as Map<String, dynamic>;
              final id = buses[index].id;

              return FutureBuilder<String>(
                future: getHeure(id),
                builder: (context, snapHeure) {
                  final heure = snapHeure.data ?? "—";

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),

                    child: ListTile(
                      leading: Icon(
                        Icons.directions_bus,
                        color: getColor(data['status'] ?? ""),
                      ),

                      title: Text(data['nom'] ?? "—"),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Chauffeur: ${data['chauffeur'] ?? "—"}"),
                          Text("Heure: $heure"),
                          Text("Status: ${data['status'] ?? "—"}"),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue),
                            onPressed: () {
                              updateBus(context, id, data);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () {
                              deleteBus(id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                buildSnackBar("Bus supprimé avec succès 🗑️"),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
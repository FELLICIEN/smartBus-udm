import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartbusudm/pages/add/add_bus.dart';
import 'package:smartbusudm/pages/bus/buspage.dart';

class AdminBusPage extends StatefulWidget {
  const AdminBusPage({super.key});

  @override
  State<AdminBusPage> createState() => _AdminBusPageState();
}

class _AdminBusPageState extends State<AdminBusPage> {
  String search = "";
  String selectedFilter = "Tous";

  Stream<QuerySnapshot> getBuses() {
    return FirebaseFirestore.instance
        .collection('buses')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getChauffeurs() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'chauffeur')
        .snapshots();
  }

  /// 🔒 Vérifie qu'un chauffeur n'est pas déjà assigné à un AUTRE bus
  /// (currentBusId est exclu de la vérification, pour permettre de garder
  /// le chauffeur déjà assigné à ce bus précis)
  Future<bool> isChauffeurAvailable(
    String chauffeurId,
    String currentBusId,
  ) async {
    final existing = await FirebaseFirestore.instance
        .collection('buses')
        .where('chauffeurId', isEqualTo: chauffeurId)
        .get();

    final assignedToOtherBus =
        existing.docs.any((doc) => doc.id != currentBusId);
    return !assignedToOtherBus;
  }

  Color getColor(String status) {
    switch (status.toLowerCase()) {
      case "disponible":
        return Colors.green;
      case "en service":
        return Colors.orange;
      case "en panne":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> deleteBus(String id) async {
    await FirebaseFirestore.instance.collection('buses').doc(id).delete();
  }

  Widget buildFilterCard({
    required String title,
    required int count,
    required Color color,
    required String filter,
  }) {
    final isSelected = selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateBus(BuildContext context, String id, Map<String, dynamic> data) {
    final nom = TextEditingController(text: data['nom'] ?? "");
    final numero = TextEditingController(text: data['numero'] ?? "");
    final capacite =
        TextEditingController(text: (data['capacite'] ?? "").toString());

    String status = (data['status'] ?? "Disponible").toString();

    String? selectedChauffeurId = data['chauffeurId'];
    String? selectedChauffeurName = data['chauffeur'];

    const statuses = ["Disponible", "En service", "En panne"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            String modalError = "";

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Modifier le bus",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nom,
                      decoration: const InputDecoration(
                        labelText: "Nom du bus",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: numero,
                      decoration: const InputDecoration(
                        labelText: "Numéro",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// 👇 CHAUFFEUR DROPDOWN — n'affiche que les chauffeurs
                    /// LIBRES + celui déjà assigné à CE bus (garantit la
                    /// relation 1-pour-1 entre bus et chauffeur)
                    StreamBuilder<QuerySnapshot>(
                      stream: getBuses(),
                      builder: (context, busSnapshot) {
                        if (!busSnapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        // 🔒 chauffeurs assignés à un AUTRE bus que celui-ci
                        final assignedElsewhere = busSnapshot.data!.docs
                            .where((doc) => doc.id != id)
                            .map((doc) => (doc.data()
                                as Map<String, dynamic>)['chauffeurId'])
                            .where((cid) => cid != null)
                            .cast<String>()
                            .toSet();

                        return StreamBuilder<QuerySnapshot>(
                          stream: getChauffeurs(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            final chauffeurs = snapshot.data!.docs
                                .where((doc) =>
                                    !assignedElsewhere.contains(doc.id))
                                .toList();

                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedChauffeurId,
                                hint: const Text("Choisir un chauffeur"),
                                underline: const SizedBox(),
                                items: chauffeurs.map((doc) {
                                  final d = doc.data() as Map<String, dynamic>;
                                  return DropdownMenuItem(
                                    value: doc.id,
                                    child: Text(d['nom'] ?? "Sans nom"),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setStateModal(() {
                                    selectedChauffeurId = value;
                                    selectedChauffeurName = chauffeurs
                                        .firstWhere((e) => e.id == value)
                                        .get('nom');
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: capacite,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Capacité",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: status,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: statuses
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setStateModal(() {
                            status = value!;
                          });
                        },
                      ),
                    ),

                    if (modalError.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        modalError,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedChauffeurId == null) {
                            setStateModal(() {
                              modalError = "Veuillez choisir un chauffeur";
                            });
                            return;
                          }

                          // 🔒 Double vérification anti-conflit (protège
                          // contre deux modifications concurrentes)
                          final available = await isChauffeurAvailable(
                            selectedChauffeurId!,
                            id,
                          );
                          if (!available) {
                            setStateModal(() {
                              modalError =
                                  "Ce chauffeur est déjà assigné à un autre bus";
                            });
                            return;
                          }

                          await FirebaseFirestore.instance
                              .collection('buses')
                              .doc(id)
                              .update({
                            'nom': nom.text,
                            'numero': numero.text,
                            'capacite': int.tryParse(capacite.text) ?? 0,
                            'status': status,
                            'chauffeurId': selectedChauffeurId,
                            'chauffeur': selectedChauffeurName,
                          });

                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text("Enregistrer"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Gestion des bus",style: TextStyle(fontWeight: FontWeight.bold,fontFamily: "BoostPlay",color: Colors.white,fontSize: 28),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getBuses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBuses = snapshot.data!.docs;

          final total = allBuses.length;
          final dispo = allBuses
              .where((d) => d['status'] == "Disponible")
              .length;
          final service = allBuses
              .where((d) => d['status'] == "En service")
              .length;
          final panne =
              allBuses.where((d) => d['status'] == "En panne").length;

          List<QueryDocumentSnapshot> filtered = allBuses;

          if (selectedFilter != "Tous") {
            filtered = filtered
                .where((d) => d['status'] == selectedFilter)
                .toList();
          }

          filtered = filtered.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['nom']
                .toString()
                .toLowerCase()
                .contains(search.toLowerCase());
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 10),

              Row(
                children: [
                  buildFilterCard(
                      title: "Tous",
                      count: total,
                      color: Colors.blue,
                      filter: "Tous"),
                  buildFilterCard(
                      title: "Disponible",
                      count: dispo,
                      color: Colors.green,
                      filter: "Disponible"),
                  buildFilterCard(
                      title: "En service",
                      count: service,
                      color: Colors.orange,
                      filter: "En service"),
                  buildFilterCard(
                      title: "En panne",
                      count: panne,
                      color: Colors.red,
                      filter: "En panne"),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged: (v) => setState(() => search = v),
                  decoration: const InputDecoration(
                     border: OutlineInputBorder(
                      borderRadius: BorderRadius.all( Radius.circular(12)),
                     ),
                    hintText: "Rechercher...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.directions_bus, color: Colors.white),
                          backgroundColor: getColor(data['status']),
                        ),
                        title: Text("Bus ${data['nom']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Chauffeur: ${data['chauffeur']}"),
                            Text("Capacité: ${data['capacite']}"),
                            Text("Status: ${data['status']}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,color: Colors.blue,size: 40,),
                              onPressed: () =>
                                  updateBus(context, doc.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,color: Colors.red,size: 40,),
                              onPressed: () => deleteBus(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus), label: "Bus"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: "Ajouter"),
        ],
        onTap: (i) {
          if (i == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminBusPage()));
          }
          if (i == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddBusPage()));
          }
        },
      ),
    );
  }
}
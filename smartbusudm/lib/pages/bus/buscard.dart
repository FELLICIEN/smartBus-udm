import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BusCard extends StatelessWidget {
  final String busId;
  final String passageId;
  final String busNumber;
  final String status;
  final Color color;
  final String chauffeurId;
  final String heure;

  const BusCard({
    super.key,
    required this.busId,
    required this.passageId,
    required this.busNumber,
    required this.status,
    required this.color,
    required this.chauffeurId,
    required this.heure,
  });

  /// 🎨 COULEUR STATUS
  Color getStatusColor(String status) {
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

  /// 👨‍✈️ NOM CHAUFFEUR
  Future<String> getChauffeurName() async {
    try {
      if (chauffeurId.isEmpty) {
        return "Non défini";
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(chauffeurId)
          .get();

      if (doc.exists) {
        return doc.data()?["nom"] ?? "Inconnu";
      }

      return "Inconnu";
    } catch (e) {
      debugPrint("Erreur chauffeur : $e");
      return "Erreur";
    }
  }

  /// ✏️ MODIFIER BUS
  void showEditDialog(BuildContext context) {
    final heureCtrl = TextEditingController(text: heure);

    String currentStatus = status;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Modifier Bus",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// 🕒 HEURE
                  TextField(
                    controller: heureCtrl,
                    decoration: const InputDecoration(
                      labelText: "Heure prévue",
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🚦 STATUS
                  DropdownButtonFormField<String>(
                    initialValue: currentStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      "Disponible",
                      "En service",
                      "En panne",
                    ]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        currentStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Annuler"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    try {

                      /// UPDATE BUS
                      await FirebaseFirestore.instance
                          .collection("buses")
                          .doc(busId)
                          .update({
                        "status": currentStatus,
                      });

                      /// UPDATE PASSAGE
                      await FirebaseFirestore.instance
                          .collection("passages")
                          .doc(passageId)
                          .update({
                        "heurePrevue": heureCtrl.text,
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Bus modifié ✅"),
                        ),
                      );
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                  child: const Text("Sauvegarder"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ❌ SUPPRIMER
  Future<void> deleteBus(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("passages")
          .doc(passageId)
          .delete();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Passage supprimé ❌"),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 📄 LIGNE INFO
  Widget infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.blue,
          ),

          const SizedBox(width: 12),

          Text(
            "$title : ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// 🔍 DETAILS
  void showDetails(BuildContext context) async {
    bool isAdmin = false;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        isAdmin = userDoc.data()?["role"] == "admin";
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Text(
            "Bus $busNumber",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// 🚌 ICON
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 60,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 25),

              /// 🕒 HEURE
              infoRow(
                Icons.access_time,
                "Heure",
                heure,
              ),

              /// 🚦 STATUS
              infoRow(
                Icons.info,
                "Statut",
                status,
              ),

              /// 👨‍✈️ CHAUFFEUR
              FutureBuilder<String>(
                future: getChauffeurName(),
                builder: (context, snapshot) {
                  return infoRow(
                    Icons.person,
                    "Chauffeur",
                    snapshot.data ?? "Chargement...",
                  );
                },
              ),
            ],
          ),
          actions: [

            /// ADMIN
            if (isAdmin) ...[

              TextButton(
                onPressed: () {
                  deleteBus(context);
                },
                child: const Text(
                  "Supprimer",
                  style: TextStyle(color: Colors.red),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showEditDialog(context);
                },
                child: const Text("Modifier"),
              ),
            ]

            else

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Fermer"),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(status);

    return InkWell(
      borderRadius: BorderRadius.circular(20),

      /// ✅ CLICK
      onTap: () {
        showDetails(context);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              // ignore: deprecated_member_use
              statusColor.withOpacity(0.08),
              // ignore: deprecated_member_use
              statusColor.withOpacity(0.18),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // ignore: deprecated_member_use
            color: statusColor.withOpacity(0.25),
          ),
        ),

        child: Row(
          children: [

            /// 🕒 + 👨‍✈️
            Column(
              children: [

                /// HEURE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    heure,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                /// CHAUFFEUR
                SizedBox(
                  width: 85,
                  child: FutureBuilder<String>(
                    future: getChauffeurName(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "Chargement...",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(width: 20),

            /// 🚌 ICON
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.directions_bus,
                color: statusColor,
                size: 28,
              ),
            ),

            const SizedBox(width: 18),

            /// 📄 INFOS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Bus $busNumber",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "⏰  $heure",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            /// 🚦 STATUS
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
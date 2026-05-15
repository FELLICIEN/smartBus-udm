import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smartbusudm/pages/gps.dart';

class AllBusPage extends StatefulWidget {
  const AllBusPage({super.key});

  @override
  State<AllBusPage> createState() => _AllBusPageState();
}

class _AllBusPageState extends State<AllBusPage> {
  String selectedFilter = "Tous";

  Stream<QuerySnapshot> getBuses() {
    return FirebaseFirestore.instance
        .collection('buses')
        .orderBy('nom')
        .snapshots();
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
        return Colors.grey;
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return "Non définie";
    if (date is Timestamp) {
      return DateFormat('dd/MM/yyyy - HH:mm').format(date.toDate());
    }
    return date.toString();
  }

  Future<String> getChauffeurName(String chauffeurId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(chauffeurId)
          .get();

      if (doc.exists) {
        return doc.data()?['nom'] ?? "Chauffeur inconnu";
      }
    } catch (_) {}
    return "Chauffeur inconnu";
  }

  /// 🔥 FILTER
  List<QueryDocumentSnapshot> filterBuses(List<QueryDocumentSnapshot> buses) {
    if (selectedFilter == "Tous") return buses;

    return buses.where((bus) {
      final status = (bus['status'] ?? "").toString().toLowerCase();

      if (selectedFilter == "Disponible") return status == "disponible";
      if (selectedFilter == "En service") return status == "en service";
      if (selectedFilter == "En panne") return status == "en panne";

      return true;
    }).toList();
  }

  Widget buildFilterButton(String label, int count, Color color) {
    final isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          "$label ($count)",
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: Column(
        children: [

          /// 🔥 HEADER
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bus2.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.55),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Text(
                    "SmartBus",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Gestion des bus en temps réel",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 📊 FILTER + STATS
          StreamBuilder<QuerySnapshot>(
            stream: getBuses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final buses = snapshot.data!.docs;

              final total = buses.length;
              final dispo = buses.where((b) =>
                  (b['status'] ?? "").toString().toLowerCase() ==
                  "disponible").length;

              final service = buses.where((b) =>
                  (b['status'] ?? "").toString().toLowerCase() ==
                  "en service").length;

              final panne = buses.where((b) =>
                  (b['status'] ?? "").toString().toLowerCase() ==
                  "en panne").length;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [

                    buildFilterButton("Tous", total, Colors.blue),
                    const SizedBox(width: 8),
                    buildFilterButton("Disponible", dispo, Colors.green),
                    const SizedBox(width: 8),
                    buildFilterButton("En service", service, Colors.orange),
                    const SizedBox(width: 8),
                    buildFilterButton("En panne", panne, Colors.red),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          /// 🚍 LISTE BUS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getBuses(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBuses = snapshot.data!.docs;
                final buses = filterBuses(allBuses);

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus =
                        buses[index].data() as Map<String, dynamic>;

                    final busId = buses[index].id;
                    final nom = bus['nom'] ?? "Sans nom";
                    final numero = bus['numero'] ?? "";
                    final status = bus['status'] ?? "Disponible";
                    final chauffeurId = bus['chauffeurId'];
                    final createdAt = formatDate(bus['date']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// HEADER
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: getColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.directions_bus,
                                  color: getColor(status),
                                ),
                              ),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bus $nom",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("Numéro: $numero"),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: getColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: getColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// CHAUFFEUR
                          FutureBuilder<String>(
                            future: chauffeurId != null
                                ? getChauffeurName(chauffeurId)
                                : Future.value("Non défini"),
                            builder: (context, snap) {
                              return Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 18, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  Text("Chauffeur: ${snap.data ?? '...'}"),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 6),

                          /// DATE
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 18, color: Colors.orange),
                              const SizedBox(width: 6),
                              Text("Ajouté: $createdAt"),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// GPS BUTTON (CLICABLE)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: getColor(status),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Gps(
                                      busId: busId,
                                      busName: nom,
                                      busStatus: status,
                                      busLocation:
                                          "latitude : 12.2215\nlongitude : 48.8566",
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.location_on,
                                  color: Colors.white),
                              label: const Text(
                                "Voir position",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
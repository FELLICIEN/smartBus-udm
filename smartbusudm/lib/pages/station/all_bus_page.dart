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
        return const Color(0xFF22C55E);
      case "en service":
        return const Color(0xFFF59E0B);
      case "en panne":
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "disponible":
        return Icons.check_circle_outline;
      case "en service":
        return Icons.directions_bus;
      case "en panne":
        return Icons.build_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return "Non définie";
    if (date is Timestamp) {
      return DateFormat('dd MMM yyyy • HH:mm').format(date.toDate());
    }
    return date.toString();
  }

  Future<String> getChauffeurName(String chauffeurId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(chauffeurId)
          .get();
      if (doc.exists) return doc.data()?['nom'] ?? "Inconnu";
    } catch (_) {}
    return "Non assigné";
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [

          /// 🔥 HEADER
          SizedBox(
            height: 230,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/bus2.png', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // ignore: deprecated_member_use
                          Colors.blue.shade900.withOpacity(0.4),
                          // ignore: deprecated_member_use
                          Colors.blue.shade800.withOpacity(0.85),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          /// TITRE
                          const Text(
                            "Flotte de Bus",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Gestion en temps réel 🚌",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// 🔘 FILTRES
          StreamBuilder<QuerySnapshot>(
            stream: getBuses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox(height: 40);

              final buses = snapshot.data!.docs;
              final total = buses.length;
              final dispo = buses.where((b) =>
                  (b['status'] ?? "").toString().toLowerCase() == "disponible").length;
              final enService = buses.where((b) =>
                  (b['status'] ?? "").toString().toLowerCase() == "en service").length;
              final panne = buses.where((b) =>
                  (b['status'] ?? "").toString().toLowerCase() == "en panne").length;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip("Tous", total, const Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    _filterChip("Disponible", dispo, const Color(0xFF22C55E)),
                    const SizedBox(width: 8),
                    _filterChip("En service", enService, const Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    _filterChip("En panne", panne, const Color(0xFFEF4444)),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          /// 🚍 LISTE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getBuses(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final buses = filterBuses(snapshot.data!.docs);

                if (buses.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun bus trouvé",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus = buses[index].data() as Map<String, dynamic>;
                    final busId = buses[index].id;
                    final nom = bus['nom'] ?? "Sans nom";
                    final numero = bus['numero'] ?? "";
                    final status = bus['status'] ?? "Disponible";
                    final chauffeurId = bus['chauffeurId'];
                    final createdAt = formatDate(bus['date']);
                    final color = getColor(status);

                    // ✅ Coordonnées de secours = Université de Moundou,
                    // utilisées uniquement le temps que la vraie position
                    // arrive (au lieu du Golfe d'Aden précédemment codé en dur).
                    const double defaultLat = 8.5667;
                    const double defaultLng = 16.0833;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [

                          /// 🔝 CARD HEADER
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: color.withOpacity(0.06),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [

                                /// ICON BUS
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.directions_bus_rounded,
                                    color: color,
                                    size: 26,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// NOM + NUMERO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Bus $nom",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Numéro : $numero",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// STATUS BADGE
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        // ignore: deprecated_member_use
                                        color: color.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(getStatusIcon(status),
                                          size: 13, color: color),
                                      const SizedBox(width: 4),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// 📄 CARD BODY
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: Column(
                              children: [

                                /// CHAUFFEUR
                                FutureBuilder<String>(
                                  future: chauffeurId != null
                                      ? getChauffeurName(chauffeurId)
                                      : Future.value("Non assigné"),
                                  builder: (context, snap) {
                                    return _infoRow(
                                      icon: Icons.person_outline_rounded,
                                      color: Colors.blue.shade400,
                                      label: "Chauffeur",
                                      value: snap.data ?? "...",
                                    );
                                  },
                                ),

                                const SizedBox(height: 8),

                                /// DATE
                                _infoRow(
                                  icon: Icons.calendar_today_outlined,
                                  color: Colors.orange.shade400,
                                  label: "Ajouté",
                                  value: createdAt,
                                ),

                                const SizedBox(height: 14),

                                /// BOUTON GPS
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Gps(
                                            busId: busId,
                                            busName: nom,
                                            // ✅ Coordonnées de secours corrigées :
                                            // Université de Moundou au lieu du
                                            // Golfe d'Aden (12.2215, 48.8566).
                                            latitude: defaultLat,
                                            longitude: defaultLng,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: color,
                                      side: BorderSide(
                                          // ignore: deprecated_member_use
                                          color: color.withOpacity(0.5)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.location_on_outlined,
                                        size: 18),
                                    label: const Text(
                                      "Voir la position GPS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _filterChip(String label, int count, Color color) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            // ignore: deprecated_member_use
            color: isSelected ? color : color.withOpacity(0.3),
          ),
          boxShadow: isSelected
              // ignore: deprecated_member_use
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]
              : [],
        ),
        child: Text(
          "$label  $count",
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          "$label : ",
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

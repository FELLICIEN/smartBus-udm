import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartbusudm/pages/station/station_detaille_page.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key});

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  String search = "";

  Stream<QuerySnapshot> getStations() {
    return FirebaseFirestore.instance
        .collection('stations')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: Column(
        children: [

          /// 🔥 HEADER
          Container(
            height: 260,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [

                  /// 🖼️ IMAGE
                  Image.asset(
                    'assets/bus2.png',
                    fit: BoxFit.cover,
                  ),

                  /// 🔲 OVERLAY
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // ignore: deprecated_member_use
                          Colors.blue.shade900.withOpacity(0.55),
                          // ignore: deprecated_member_use
                          Colors.blue.shade700.withOpacity(0.75),
                        ],
                      ),
                    ),
                  ),

                  /// 📄 CONTENU HEADER
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// 🔝 TOP ROW
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                             

                             

                              /// 🔵 LOGO CNOU
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/cnou_icon.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          /// 🚌 TITRE + COMPTEUR
                          StreamBuilder<QuerySnapshot>(
                            stream: getStations(),
                            builder: (context, snap) {
                              final count = snap.hasData
                                  ? snap.data!.docs.length
                                  : 0;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Stations Bus",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      "$count",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          /// 📄 SOUS-TITRE
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Suivez les bus en temps réel ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text("🚌", style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔍 RECHERCHE
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 18, 15, 5),
            child: TextField(
              onChanged: (v) => setState(() => search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Rechercher une station...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// 🔥 LISTE STATIONS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getStations(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucune station"));
                }

                final filtered = snapshot.data!.docs.where((doc) {
                  final name = (doc['nom'] ?? "").toString().toLowerCase();
                  return name.contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucune station trouvée",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final station = filtered[index];
                    final adresse = station['adresse'] ?? "Sans adresse";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StationBusPage(
                              stationId: station.id,
                              stationName: station['nom'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [

                            /// 🔵 ICON
                            Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),

                            /// 📄 TEXTE
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Station ${station['nom']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    station['description'] ?? "Pas de description",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// ➡️ ADRESSE + FLECHE
                            Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 75,
                                    child: Text(
                                      adresse,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
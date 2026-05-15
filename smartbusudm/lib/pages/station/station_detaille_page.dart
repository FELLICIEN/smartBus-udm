import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:smartbusudm/pages/bus/buscard.dart';

class StationBusPage extends StatelessWidget {
  final String stationId;
  final String stationName;

  const StationBusPage({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  /// 🔥 STREAM PASSAGES
  Stream<QuerySnapshot> getPassages() {
    return FirebaseFirestore.instance
        .collection('passages')
        .where('stationId', isEqualTo: stationId)
        .snapshots();
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

  /// ⏰ FORMAT HEURE
  String formatTime(dynamic time) {
    if (time == null) return "";

    if (time is Timestamp) {
      return DateFormat('HH:mm').format(time.toDate());
    }

    return time.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Column(
          children: [

            /// 🔥 HEADER (INCHANGÉ)
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/bus2.png"),
                  fit: BoxFit.cover,
                ),
              ),

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.4),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "Station $stationName",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Liste des bus programmés",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 🔥 LISTE BUS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getPassages(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Erreur : ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun bus programmé 🚫",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  final passages = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: passages.length,

                    itemBuilder: (context, index) {
                      final passage = passages[index];
                      final data = passage.data() as Map<String, dynamic>;

                      final busId = data['busId'] ?? "";

                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('buses')
                            .doc(busId)
                            .snapshots(),

                        builder: (context, busSnapshot) {

                          if (!busSnapshot.hasData ||
                              !busSnapshot.data!.exists) {
                            return const SizedBox();
                          }

                          final bus = busSnapshot.data!.data()
                              as Map<String, dynamic>;

                          return BusCard(
                            passageId: passage.id,
                            busId: busId,

                            /// 🚌 BUS NAME (CORRECT)
                            busNumber: bus['nom'] ?? "Bus",

                            /// 🚦 STATUS
                            status: bus['status'] ?? "Disponible",

                            color: getColor(bus['status'] ?? ""),

                            /// 👨‍✈️ CHAUFFEUR CORRECT
                            chauffeurId: bus['chauffeurId'] ?? "",

                            /// ⏰ HEURE
                            heure: formatTime(data['heurePrevue']),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
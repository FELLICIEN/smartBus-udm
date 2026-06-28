
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartbusudm/services/bacground_location.dart';

class ChauffeurPage extends StatefulWidget {
  const ChauffeurPage({super.key});

  @override
  State<ChauffeurPage> createState() => _ChauffeurPageState();
}

class _ChauffeurPageState extends State<ChauffeurPage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> getBus() async {
    final result = await FirebaseFirestore.instance
        .collection('buses')
        .where('chauffeurId', isEqualTo: user!.uid)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    return {
      'id': result.docs.first.id,
      ...result.docs.first.data(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Espace Chauffeur"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// INFOS BUS
          FutureBuilder<Map<String, dynamic>?>(
            future: getBus(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }

              final bus = snapshot.data!;

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [

                      Text(
                        bus['nom'] ?? 'Bus',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text("Numéro : ${bus['numero']}"),

                      Text("Statut : ${bus['status']}"),

                      Text(
                        "Vitesse : ${(bus['vitesse'] ?? 0).toStringAsFixed(1)} km/h",
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("Démarrer"),
                              onPressed: () async {

                                await BackgroundLocationService
                                    .startService();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Trajet démarré"),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              icon: const Icon(Icons.stop),
                              label: const Text("Arrêter"),
                              onPressed: () async {

                                await BackgroundLocationService
                                    .stopService();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Trajet arrêté"),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          /// TITRE PASSAGES
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Row(
              children: const [
                Icon(Icons.route),
                SizedBox(width: 8),
                Text(
                  "Mes passages",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// LISTE PASSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('passages')
                  .where(
                    'chauffeurId',
                    isEqualTo: user!.uid,
                  )
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final passages = snapshot.data!.docs;

                if (passages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun passage trouvé",
                    ),
                  );
                }

                return Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Total : ${passages.length} passages",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: passages.length,
                        itemBuilder: (context, index) {

                          final p =
                              passages[index].data()
                                  as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.bus_alert),
                              ),

                              title: Text(
                                p['stationNom'] ?? '',
                              ),

                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    "Bus : ${p['busNom']}",
                                  ),

                                  Text(
                                    "Heure prévue : ${p['heurePrevue']}",
                                  ),
                                ],
                              ),

                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
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
          ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChauffeurPassagesPage extends StatefulWidget {
  const ChauffeurPassagesPage({super.key});

  @override
  State<ChauffeurPassagesPage> createState() =>
      _ChauffeurPassagesPageState();
}

class _ChauffeurPassagesPageState
    extends State<ChauffeurPassagesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String chauffeurId = "";
  bool loading = true;
  bool isChauffeur = false;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  Future<void> initUser() async {
    final user = auth.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    chauffeurId = user.uid;

    final userDoc =
        await firestore.collection('users').doc(chauffeurId).get();

    final data = userDoc.data() as Map<String, dynamic>;
    isChauffeur = data['role'] == 'chauffeur';

    setState(() => loading = false);
  }

  Stream<QuerySnapshot> getPassages() {
    return firestore
        .collection('passages')
        .where('userId', isEqualTo: chauffeurId)
        .orderBy('heurePrevue', descending: true)
        .snapshots();
  }

  String formatDate(Timestamp? t) {
    if (t == null) return "--";
    return DateFormat('EEE dd MMM • HH:mm').format(t.toDate());
  }

  int getDelay(Timestamp? planned) {
    if (planned == null) return 0;
    final diff = DateTime.now().difference(planned.toDate()).inMinutes;
    return diff > 0 ? diff : 0;
  }

  Color statusColor(String s) {
    switch (s.toLowerCase()) {
      case "retard":
        return Colors.orange;
      case "annulé":
        return Colors.red;
      case "passé":
        return Colors.green;
      case "a_l_heure":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String statusText(String s) {
    switch (s.toLowerCase()) {
      case "a_l_heure":
        return "À l'heure";
      case "retard":
        return "Retard";
      case "annulé":
        return "Annulé";
      case "passé":
        return "Passé";
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        title: const Text(
          "Mes passages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : !isChauffeur
              ? const Center(
                  child: Text(
                    "Accès réservé aux chauffeurs",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : StreamBuilder<QuerySnapshot>(
                  stream: getPassages(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data!.docs;

                    if (data.isEmpty) {
                      return const Center(
                        child: Text("Aucun passage trouvé 🚍"),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        final d =
                            data[i].data() as Map<String, dynamic>;

                        final bus = d['busNom'] ?? "Bus";
                        final station = d['stationNom'] ?? "Station";
                        final status = d['statut'] ?? "a_l_heure";
                        final heure = d['heurePrevue'] as Timestamp?;

                        final delay = getDelay(heure);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(16),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                /// HEADER
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade300,
                                            Colors.blue.shade700
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.directions_bus,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bus,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            station,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// STATUS CHIP
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor(status)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        statusText(status),
                                        style: TextStyle(
                                          color: statusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                /// TIME CARD
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F9FC),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          size: 18, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(formatDate(heure)),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                /// DELAY
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: delay > 0
                                        // ignore: deprecated_member_use
                                        ? Colors.red.withOpacity(0.08)
                                        // ignore: deprecated_member_use
                                        : Colors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                   children: [
                                      Icon(
                                        Icons.timer,
                                         color:
                                            delay > 0 ? Colors.red : Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        delay > 0
                                            ? "Retard : $delay min"
                                            : "À l'heure",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: delay > 0
                                              ? Colors.red
                                              : Colors.green,
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
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartbusudm/services/bacground_service.dart';

class ChauffeurPage extends StatefulWidget {
  const ChauffeurPage({super.key});

  @override
  State<ChauffeurPage> createState() => _ChauffeurPageState();
}

class _ChauffeurPageState extends State<ChauffeurPage>
    with SingleTickerProviderStateMixin {
  bool gpsActif = false;
  String busNom = "Chargement...";
  String busStatus = "Disponible";
  String busId = "";

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String get chauffeurId =>
      FirebaseAuth.instance.currentUser?.uid ?? "";

  String get nomChauffeur =>
      FirebaseAuth.instance.currentUser?.displayName ?? "Chauffeur";

  @override
  void initState() {
    super.initState();
    chargerBus();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatHeure(dynamic valeur) {
    if (valeur == null) return 'Inconnue';
    DateTime dt;
    if (valeur is Timestamp) {
      dt = valeur.toDate();
    } else if (valeur is String) {
      return valeur;
    } else {
      return 'Format invalide';
    }
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> chargerBus() async {
    final bus = await FirebaseFirestore.instance
        .collection('buses')
        .where('chauffeurId', isEqualTo: chauffeurId)
        .limit(1)
        .get();

    if (bus.docs.isNotEmpty) {
      final data = bus.docs.first.data();
      setState(() {
        busId = bus.docs.first.id;
        busNom = data['nom'] ?? 'BUS';
        busStatus = data['status'] ?? 'Disponible';
        gpsActif = data['tracking'] ?? false;
      });
    }
  }

  Future<void> demarrerGPS() async {
    try {
      final busRef = FirebaseFirestore.instance
          .collection('buses')
          .doc(busId);

      await busRef.update({'status': 'En service', 'tracking': true});
      await BackgroundLocationService.startService();

      setState(() {
        gpsActif = true;
        busStatus = "En service";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.gps_fixed, color: Colors.white),
              SizedBox(width: 10),
              Text("GPS démarré avec succès"),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Erreur START GPS: $e");
    }
  }

  Future<void> arreterGPS() async {
    try {
      final busRef = FirebaseFirestore.instance
          .collection('buses')
          .doc(busId);

      await busRef.update({'status': 'Disponible', 'tracking': false});
      await BackgroundLocationService.stopService();

      setState(() {
        gpsActif = false;
        busStatus = "Disponible";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.gps_off, color: Colors.white),
              SizedBox(width: 10),
              Text("GPS arrêté"),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Erreur STOP GPS: $e");
    }
  }

  Stream<QuerySnapshot> getPassages() {
    return FirebaseFirestore.instance
        .collection('passages')
        .where('chauffeurId', isEqualTo: chauffeurId)
        .orderBy('heurePrevue')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0A0F2C),
              Color(0xff0D2B6B),
              Color(0xff1A1060),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: chargerBus,
            color: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xff6C63FF), Color(0xff3B82F6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff6C63FF).withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bonjour 👋",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            nomChauffeur,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: gpsActif
                                ? [
                                    Colors.green.shade700,
                                    Colors.green.shade400
                                  ]
                                : [
                                    Colors.grey.shade700,
                                    Colors.grey.shade500
                                  ],
                          ),
                        ),
                        child: Text(
                          gpsActif ? "En service" : "Disponible",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// BUS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xff6C63FF),
                          Color(0xff3B82F6),
                          Color(0xff06B6D4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: const Color(0xff6C63FF).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_bus_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Text('Bus '+ busNom,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// Bouton GPS animé
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: gpsActif
                                        ? _pulseAnimation.value
                                        : 1.0,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: gpsActif
                                        ? Colors.greenAccent.shade400
                                        : Colors.white24,
                                    boxShadow: gpsActif
                                        ? [
                                            BoxShadow(
                                              color: Colors.greenAccent
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(0.6),
                                              blurRadius: 16,
                                              spreadRadius: 4,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Icon(
                                    gpsActif
                                        ? Icons.gps_fixed
                                        : Icons.gps_off,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gpsActif ? "GPS ACTIF" : "GPS INACTIF",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    gpsActif
                                        ? "Position en cours d'envoi"
                                        : "Appuyez sur START",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// BOUTONS START / STOP
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: gpsActif ? null : demarrerGPS,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: gpsActif
                                  ? LinearGradient(
                                      colors: [
                                        Colors.grey.shade700,
                                        Colors.grey.shade600
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xff22C55E),
                                        Color(0xff16A34A),
                                      ],
                                    ),
                              boxShadow: gpsActif
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: const Color(0xff22C55E)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 22),
                                SizedBox(width: 6),
                                Text(
                                  "START",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: gpsActif ? arreterGPS : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: !gpsActif
                                  ? LinearGradient(
                                      colors: [
                                        Colors.grey.shade700,
                                        Colors.grey.shade600
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xffEF4444),
                                        Color(0xffDC2626),
                                      ],
                                    ),
                              boxShadow: !gpsActif
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: const Color(0xffEF4444)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.stop_rounded,
                                    color: Colors.white, size: 22),
                                SizedBox(width: 6),
                                Text(
                                  "STOP",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  /// TITRE PASSAGES
                  const Row(
                    children: [
                      Icon(Icons.route_rounded,
                          color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Mes passages",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// LISTE PASSAGES
                  StreamBuilder<QuerySnapshot>(
                    stream: getPassages(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      if (snapshot.data!.docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white12,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Aucun passage prévu",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = snapshot.data!.docs[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  // ignore: deprecated_member_use
                                  Colors.white.withOpacity(0.08),
                                  // ignore: deprecated_member_use
                                  Colors.white.withOpacity(0.04),
                                ],
                              ),
                              border: Border.all(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff6C63FF),
                                        Color(0xff3B82F6),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.place_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text( 'Station '+ p['stationNom'] ?? 'Station',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Prévu à ${_formatHeure(p['heurePrevue'])}',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        // ignore: deprecated_member_use
                                        const Color(0xff3B82F6).withOpacity(0.2),
                                    border: Border.all(
                                      color: const Color(0xff3B82F6)
                                          // ignore: deprecated_member_use
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    _formatHeure(p['heurePrevue']),
                                    style: const TextStyle(
                                      color: Color(0xff93C5FD),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class Passage {
  final String id;
  final String busId;
  final String userId;
  final String stationId;
  

  final DateTime heurePrevue;
  final int retard;
  final String statut;

  Passage({
    required this.id,
    required this.busId,
    required this.userId,
    required this.stationId,
    required this.heurePrevue,
    required this.retard,
    required this.statut,
  });

  /// 🔄 Firestore → Objet (SAFE)
  factory Passage.fromMap(Map<String, dynamic> data, String documentId) {
    return Passage(
      id: documentId,
      busId: data['busId'] ?? '',
      userId: data['userId'] ?? '',
      stationId: data['stationId'] ?? '',

      heurePrevue: (data['heurePrevue'] != null)
          ? (data['heurePrevue'] as Timestamp).toDate()
          : DateTime.now(),

      retard: data['retard'] ?? 0,
      statut: data['statut'] ?? 'a_l_heure',
    );
  }

  /// 🔄 Objet → Firestore
  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'stationId': stationId,
      'userId': userId,
      'heurePrevue': Timestamp.fromDate(heurePrevue),
      'retard': retard,
      'statut': statut,
    };
  }

  /// 🧠 calcul retard
  static int calculerRetard(DateTime prevue, DateTime reelle) {
    return reelle.difference(prevue).inMinutes;
  }

  /// 🧠 statut automatique
  static String getStatut(int retard) {
    if (retard <= 0) return "a_l_heure";
    if (retard <= 5) return "leger_retard";
    return "retard";
  }
}
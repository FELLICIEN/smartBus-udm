import 'package:cloud_firestore/cloud_firestore.dart';

class Passage {
  final String id;
  final String busId;
  final String busNom;

  final String chauffeurId;
  final String chauffeurNom;

  final String userId;
  final String stationId;

  final DateTime heurePrevue;
  final int retard;
  final String status;

  Passage({
    required this.id,
    required this.busId,
    required this.busNom,
    required this.chauffeurId,
    required this.chauffeurNom,
    required this.userId,
    required this.stationId,
    required this.heurePrevue,
    required this.retard,
    required this.status,
  });

  factory Passage.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return Passage(
      id: documentId,

      busId: data['busId'] ?? '',
      busNom: data['busNom'] ?? '',

      chauffeurId: data['chauffeurId'] ?? '',
      chauffeurNom: data['chauffeurNom'] ?? '',

      userId: data['userId'] ?? '',
      stationId: data['stationId'] ?? '',

      heurePrevue: data['heurePrevue'] != null
          ? (data['heurePrevue'] as Timestamp).toDate()
          : DateTime.now(),

      retard: data['retard'] ?? 0,
      status: data['status'] ?? 'Disponible',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'busNom': busNom,

      'chauffeurId': chauffeurId,
      'chauffeurNom': chauffeurNom,

      'stationId': stationId,
      'userId': userId,

      'heurePrevue': Timestamp.fromDate(heurePrevue),

      'retard': retard,
      'status': status,
    };
  }

  static int calculerRetard(
    DateTime prevue,
    DateTime reelle,
  ) {
    return reelle.difference(prevue).inMinutes;
  }

  static String getStatut(int retard) {
    if (retard <= 0) return "a_l_heure";
    if (retard <= 5) return "leger_retard";
    return "retard";
  }
}
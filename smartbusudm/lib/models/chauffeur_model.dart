

class ChauffeurModel {
  final String id;
  final String nom;
  final String email;
  final String telephone;
  final String busId;
  final String role;

  ChauffeurModel({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.busId,
    required this.role,
  });

  // Convertir Firestore -> Objet
  factory ChauffeurModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ChauffeurModel(
      id: documentId,
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      busId: map['busId'] ?? '',
      role: map['role'] ?? 'chauffeur',
    );
  }

  // Convertir Objet -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'busId': busId,
      'role': role,
    };
  }
}
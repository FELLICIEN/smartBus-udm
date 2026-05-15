class Station {
  final String id;
  final String nom;
  final String description;

  final String adresse; // lignes de bus qui passent ici

  Station({
    required this.id,
    required this.nom,
    required this.description,
    required this.adresse,
  });

  // 🔄 Firestore → Objet
  factory Station.fromMap(Map<String, dynamic> data, String documentId) {
    return Station(
      id: documentId,
      nom: data['nom'] ?? '',
      description: data['description'] ?? '',
      adresse: data['adresse'] ?? '',
    );
  }

  // 🔄 Objet → Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'adresse': adresse  ,
    };
  }
}
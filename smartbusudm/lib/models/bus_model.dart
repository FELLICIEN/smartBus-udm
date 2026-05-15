
class Bus {
  final String id;
  final String nom;
  final String numero;
  final int capacite;
  final String chauffeur; // Nom du chauffeur (pour affichage)
  final String chauffeurId;
  final DateTime date;
  final String status; // "en service", "en maintenance", etc.

  Bus({
    required this.id,
    required this.nom,
    required this.numero,
    required this.capacite,
    required this.chauffeur,
    required this.chauffeurId,
    required this.date,
    required this.status,
  });

  

  // Convertir Firestore → Objet
  factory Bus.fromMap(Map<String, dynamic> data, String documentId) {
    return Bus(
      id: documentId,
      nom: data['nom'] ?? '',
      numero: data['numero'] ?? '',
      capacite: data['capacite'] ?? 0,
      chauffeur: data['chauffeur'] ?? '',
      chauffeurId: data['chauffeurId'] ?? '',
      date: data['date'] ?? DateTime.now(),
      status: data['status'] ?? 'Disponible',
    );
  }

  // Convertir Objet → Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'numero': numero,
      'capacite': capacite,
      'chauffeur': chauffeur,
      'chauffeurId':chauffeurId,
      'date': date,
      'status': status,
    };
  }
}
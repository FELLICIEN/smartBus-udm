class AppUser {
  final String uid;
  final String nom;
  final String email;
  final String role;

  AppUser({
    required this.uid,
    required this.nom,
    required this.email,
    this.role = "user",
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nom': nom,
      'email': email,
      'role': role,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      uid: data['uid'] ?? id,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }
}
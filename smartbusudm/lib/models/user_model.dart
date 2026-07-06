class AppUser {
  final String uid;
  final String nom;
  final String email;
  final String role;
  final String? photoUrl;
 
  AppUser({
    required this.uid,
    required this.nom,
    required this.email,
    this.role = "user",
    this.photoUrl,
  });
 
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nom': nom,
      'email': email,
      'role': role,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
 
  factory AppUser.fromMap(Map<String, dynamic> data, String id) {
    return AppUser(
      uid: data['uid'] ?? id,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      photoUrl: data['photoUrl'],
    );
  }
}
 

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String nom,
    required String email,
    required String password,
  }) async {
    try {
      // Création compte Firebase
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        AppUser newUser = AppUser(
          uid: user.uid,
          nom: nom,
          email: email,
          role: "user",
        );

        await _db
            .collection('users')
            .doc(user.uid)
            .set(newUser.toMap());
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase
      if (e.code == 'email-already-in-use') {
        throw Exception("Cet email est déjà utilisé");
      } else if (e.code == 'invalid-email') {
        throw Exception("Email invalide");
      } else if (e.code == 'weak-password') {
        throw Exception("Mot de passe trop faible (min 6 caractères)");
      } else {
        throw Exception(e.message ?? "Erreur inconnue");
      }
    } catch (e) {
      throw Exception("Erreur: $e");
    }
  }
}
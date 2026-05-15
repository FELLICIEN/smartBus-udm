import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartbusudm/models/user_model.dart';

class UserService {
  final usersRef = FirebaseFirestore.instance.collection('users');

  Stream<List<AppUser>> getUsers() {
    return usersRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// 🗑️ DELETE USER
  Future<void> deleteUser(String id) async {
    await usersRef.doc(id).delete();
  }

  /// 👮 CHANGE ROLE
  Future<void> updateRole(String id, String role) async {
    await usersRef.doc(id).update({
      'role': role,
    });
  }

  /// 🔎 SEARCH USERS
  Stream<List<AppUser>> searchUsers(String query) {
    return usersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .where((user) =>
              user.nom.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
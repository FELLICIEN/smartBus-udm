import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessageService {
  final messagesRef =
      FirebaseFirestore.instance.collection('messages');

  /// 📩 SEND MESSAGE
 Future<void> sendMessage(String text) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  /// récupérer le nom depuis users
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final userData = userDoc.data();

  await FirebaseFirestore.instance.collection('messages').add({
    'text': text,
    'senderId': user.uid,
    'senderName': userData?['nom'] ?? '',
    'timestamp': FieldValue.serverTimestamp(),
  });
}

  /// 📡 STREAM MESSAGES
  Stream<List<Message>> getMessages() {
    return messagesRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  /// 🗑️ DELETE MESSAGE (OWNER / ADMIN)
  Future<void> deleteMessage({
    required Message message,
    required String currentUserId,
    required String role,
  }) async {
    final isOwner = message.senderId == currentUserId;
    final isAdmin = role == "admin";

    if (!isOwner && !isAdmin) {
      throw Exception("Non autorisé");
    }

    await messagesRef.doc(message.id).delete();
  }
}
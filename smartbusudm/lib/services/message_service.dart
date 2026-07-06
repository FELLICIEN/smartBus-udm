import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessageService {
  final messagesRef = FirebaseFirestore.instance.collection('messages');
  final typingRef = FirebaseFirestore.instance.collection('typing_status');
  final usersRef = FirebaseFirestore.instance.collection('users');

  /// 📩 ENVOYER UN MESSAGE (texte, et/ou réponse à un autre message)
  Future<void> sendMessage(
    String text, {
    Message? replyTo,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await usersRef.doc(user.uid).get();
    final userData = userDoc.data();

    await messagesRef.add({
      'text': text,
      'senderId': user.uid,
      'senderName': userData?['nom'] ?? '',
      'senderRole': userData?['role'] ?? 'user',
      if (userData?['photoUrl'] != null) 'senderPhotoUrl': userData?['photoUrl'],
      'timestamp': FieldValue.serverTimestamp(),
      if (replyTo != null) 'replyToId': replyTo.id,
      if (replyTo != null) 'replyToText': replyTo.text,
      if (replyTo != null) 'replyToSender': replyTo.senderName,
      'reactions': {},
    });

    // On coupe le statut "en train d'écrire" une fois le message envoyé
    await setTyping(false);
  }

  /// 📡 STREAM DES MESSAGES RÉCENTS (limité pour économiser les lectures Firestore)
  Stream<List<Message>> getMessages({int limit = 50}) {
    return messagesRef
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// 📜 CHARGER LES MESSAGES PLUS ANCIENS QUE "before" (pagination)
  Future<MessagePage> loadOlderMessages({
    required DateTime before,
    int limit = 30,
  }) async {
    final snapshot = await messagesRef
        .orderBy('timestamp', descending: true)
        .where('timestamp', isLessThan: Timestamp.fromDate(before))
        .limit(limit)
        .get();

    final messages = snapshot.docs
        .map((doc) => Message.fromMap(doc.data(), doc.id))
        .toList();

    return MessagePage(
      messages: messages,
      hasMore: snapshot.docs.length == limit,
    );
  }

  /// 🗑️ SUPPRIMER UN MESSAGE (propriétaire ou admin)
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

  /// ❤️ AJOUTER / RETIRER UNE RÉACTION (toggle si même emoji)
  Future<void> toggleReaction(String messageId, String uid, String emoji) async {
    final docRef = messagesRef.doc(messageId);
    final doc = await docRef.get();
    final data = doc.data();
    final reactions = Map<String, String>.from(data?['reactions'] ?? {});

    if (reactions[uid] == emoji) {
      reactions.remove(uid);
    } else {
      reactions[uid] = emoji;
    }

    await docRef.update({'reactions': reactions});
  }

  /// ⌨️ METTRE À JOUR LE STATUT "EN TRAIN D'ÉCRIRE"
  Future<void> setTyping(bool isTyping) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await usersRef.doc(user.uid).get();
    final name = userDoc.data()?['nom'] ?? '';

    await typingRef.doc(user.uid).set({
      'name': name,
      'isTyping': isTyping,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 👀 STREAM DES UTILISATEURS EN TRAIN D'ÉCRIRE (hors soi-même)
  /// On ignore un statut "isTyping" vieux de plus de 6s (ex: app fermée brutalement)
  Stream<List<String>> getTypingUsers(String currentUserId) {
    return typingRef.snapshots().map((snapshot) {
      final cutoff = DateTime.now().subtract(const Duration(seconds: 6));
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
            return doc.id != currentUserId &&
                data['isTyping'] == true &&
                updatedAt != null &&
                updatedAt.isAfter(cutoff);
          })
          .map((doc) => (doc.data()['name'] as String?) ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }

  /// ✅ MARQUER LE CHAT COMME LU (à appeler à l'ouverture de la page)
  Future<void> markAsRead(String uid) async {
    await usersRef.doc(uid).set(
      {'lastSeenChat': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// 🔔 STREAM DU NOMBRE DE MESSAGES NON LUS
  /// Utilisable dans n'importe quelle autre page (Drawer, AllBusPage, etc.)
  /// pour afficher un badge, ex: StreamBuilder<int>(stream: service.getUnreadCount(uid), ...)
  Stream<int> getUnreadCount(String uid) async* {
    final userDoc = await usersRef.doc(uid).get();
    final lastSeen =
        (userDoc.data()?['lastSeenChat'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);

    yield* messagesRef
        .where('timestamp', isGreaterThan: Timestamp.fromDate(lastSeen))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.where((d) => d.data()['senderId'] != uid).length);
  }
}

/// 📦 Résultat d'une page de messages plus anciens
class MessagePage {
  final List<Message> messages;
  final bool hasMore;

  MessagePage({required this.messages, required this.hasMore});
}
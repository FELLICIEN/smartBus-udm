import 'package:cloud_firestore/cloud_firestore.dart';
 
class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderRole; // "user" | "chauffeur" | "admin"
  final String? senderPhotoUrl;
  final DateTime timestamp;
 
  /// 💬 Réponse à un message précis
  final String? replyToId;
  final String? replyToText;
  final String? replyToSender;
 
  /// ❤️ Réactions : uid -> emoji
  final Map<String, String> reactions;
 
  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderPhotoUrl,
    required this.timestamp,
    this.replyToId,
    this.replyToText,
    this.replyToSender,
    this.reactions = const {},
  });
 
  factory Message.fromMap(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? 'user',
      senderPhotoUrl: data['senderPhotoUrl'],
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : (data['timestamp'] is DateTime
              ? data['timestamp'] as DateTime
              : DateTime.now()),
      replyToId: data['replyToId'],
      replyToText: data['replyToText'],
      replyToSender: data['replyToSender'],
      reactions: data['reactions'] != null
          ? Map<String, String>.from(data['reactions'])
          : {},
    );
  }
 
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      if (senderPhotoUrl != null) 'senderPhotoUrl': senderPhotoUrl,
      'timestamp': FieldValue.serverTimestamp(),
      if (replyToId != null) 'replyToId': replyToId,
      if (replyToText != null) 'replyToText': replyToText,
      if (replyToSender != null) 'replyToSender': replyToSender,
      'reactions': reactions,
    };
  }
}
 

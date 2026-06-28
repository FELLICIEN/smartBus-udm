import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:smartbusudm/models/message_model.dart';
import 'package:smartbusudm/services/message_service.dart';
import 'package:smartbusudm/widgets/chat_input.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final service = MessageService();
  final ScrollController _scrollController = ScrollController();

  String role = "user";
  String userName = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    setState(() {
      role = doc.data()?['role'] ?? "user";
      userName = doc.data()?['nom'] ?? "";
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// 🔥 DIALOG CONFIRMATION SUPPRESSION
  Future<void> confirmDelete(BuildContext context, String messageId) async {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🏷️ TITRE
              const Text(
                "Supprimer",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              /// 📄 DESCRIPTION
              const Text(
                "Voulez-vous supprimer ce message ?",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              /// 🔘 BOUTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// ❌ ANNULER
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// 🔴 SUPPRIMER
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await deleteMessage(messageId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Supprimer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return "";
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return "";
    }
    return DateFormat('DD/MM/yy  HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // ignore: deprecated_member_use
        backgroundColor: Colors.transparent,

    body: Container(
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/bacg.jpg'),
      fit: BoxFit.cover,
    ),
  ),
  child: StreamBuilder<List<Message>>(

     
        stream: service.getMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!;

          WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.senderId == currentUser!.uid;
              final canDelete = isMe || role == "admin";

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    /// 👤 AVATAR (autres users)
                    if (!isMe) ...[
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          msg.senderName.isNotEmpty
                              ? msg.senderName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    /// 💬 BUBBLE
                    Flexible(
                      child: GestureDetector(
                        onLongPress: canDelete
                            ? () => confirmDelete(context, msg.id)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: isMe
                                  ? const Radius.circular(18)
                                  : const Radius.circular(4),
                              bottomRight: isMe
                                  ? const Radius.circular(4)
                                  : const Radius.circular(18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// 🏷️ NOM EXPÉDITEUR
                              if (!isMe)
                                Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 14,
                                  ),
                                ),

                              if (!isMe) const SizedBox(height: 3),

                              /// 📝 TEXTE
                              Text(
                                msg.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// 🕐 HEURE + CHECK (mes messages)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatDate(msg.timestamp),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.done_all,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      )),

      /// 📩 INPUT
      bottomNavigationBar: ChatInput(
        onSend: (text) async {
          await service.sendMessage(text);
          scrollToBottom();
        },
      ),
    );
  }
}
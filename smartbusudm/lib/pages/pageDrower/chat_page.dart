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

  /// 🔥 SCROLL AUTO (compatible reverse)
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // 👈 important avec reverse:true
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 🗑 SUPPRESSION MESSAGE
  Future<void> deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  /// 📅 FORMAT DATE SAFE (Timestamp + DateTime)
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

    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat",
        style: TextStyle(
          
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
        backgroundColor: Colors.blue,
      ),

      body: StreamBuilder<List<Message>>(
        stream: service.getMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom();
          });

          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isMe = msg.senderId == currentUser!.uid;
              final canDelete = isMe || role == "admin";

              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 5, horizontal: 10),
                child: Row(
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 👤 avatar autre user
                    if (!isMe)
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Text(
                          msg.senderName.isNotEmpty
                              ? msg.senderName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                    const SizedBox(width: 8),

                    /// 💬 MESSAGE BUBBLE
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                msg.senderName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),

                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 17,
                                color: isMe
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatDate(msg.timestamp),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// 🔥 MENU SUPPRESSION
                                if (canDelete)
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      size: 18,
                                      color: isMe
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onSelected: (value) async {
                                      if (value == "delete") {
                                        await deleteMessage(msg.id);
                                      }
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: "delete",
                                        child: Icon(Icons.delete,color: Colors.red,),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

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
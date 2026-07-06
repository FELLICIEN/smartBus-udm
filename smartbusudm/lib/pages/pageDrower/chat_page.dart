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
  final TextEditingController _searchController = TextEditingController();

  String role = "user";
  String userName = "";
  String? currentUid;

  bool isSearching = false;
  String searchQuery = "";

  Message? replyingTo;

  // 📜 Pagination : messages plus anciens chargés au scroll
  List<Message> olderMessages = [];
  List<Message> liveMessages = [];
  bool hasMoreOlder = true;
  bool isLoadingMore = false;
  String? _lastTopMessageId;

  static const reactionEmojis = ["👍", "❤️", "😂", "😮", "😢"];

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser?.uid;
    loadUserData();
    // Charge automatiquement les messages plus anciens quand on approche
    // du haut du chat (reverse:true => le "haut" correspond à maxScrollExtent)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        loadMoreMessages();
      }
    });
  }

  /// 📜 Charge une page supplémentaire de messages plus anciens
  Future<void> loadMoreMessages() async {
    if (isLoadingMore || !hasMoreOlder) return;

    final allCurrent = [...liveMessages, ...olderMessages];
    if (allCurrent.isEmpty) return;

    setState(() => isLoadingMore = true);

    final page = await service.loadOlderMessages(
      before: allCurrent.last.timestamp,
      limit: 30,
    );

    if (!mounted) return;
    setState(() {
      olderMessages.addAll(page.messages);
      hasMoreOlder = page.hasMore;
      isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    // On coupe le statut de frappe si l'utilisateur quitte le chat en écrivant
    service.setTyping(false);
    super.dispose();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      role = doc.data()?['role'] ?? "user";
      userName = doc.data()?['nom'] ?? "";
    });
    // Marque le chat comme lu dès l'ouverture (pour le badge de non-lus ailleurs)
    await service.markAsRead(uid);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Supprimer",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                "Voulez-vous supprimer ce message ?",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Annuler",
                      style: TextStyle(
                          fontSize: 16, color: Colors.indigo, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await deleteMessage(messageId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text("Supprimer",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🛠️ MENU D'OPTIONS SUR UN MESSAGE (réagir / répondre / supprimer)
  void showMessageOptions(BuildContext context, Message msg, bool canDelete) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: reactionEmojis.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      service.toggleReaction(msg.id, currentUid!, emoji);
                      Navigator.pop(ctx);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  );
                }).toList(),
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.reply, color: Colors.indigo),
                title: const Text("Répondre"),
                onTap: () {
                  setState(() => replyingTo = msg);
                  Navigator.pop(ctx);
                },
              ),
              if (canDelete)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Supprimer"),
                  onTap: () {
                    Navigator.pop(ctx);
                    confirmDelete(context, msg.id);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
    return DateFormat('dd/MM/yy à HH:mm').format(date);
  }

  /// 🏷️ BADGE DE RÔLE (même style que la page Profil : chauffeur / admin / étudiant)
  Widget roleBadge(String senderRole) {
    switch (senderRole) {
      case "chauffeur":
        return _badge("Chauffeur", Icons.directions_bus, Colors.orange.shade700);
      case "admin":
        return _badge("Admin", Icons.shield, Colors.purple.shade700);
      default:
        return _badge("Étudiant(e)", Icons.school, Colors.blue.shade700);
    }
  }

  Widget _badge(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  /// 👤 AVATAR : affiche la photo de profil si disponible, sinon l'initiale
  Widget buildAvatar(Message msg, {double radius = 18}) {
    final hasPhoto = msg.senderPhotoUrl != null && msg.senderPhotoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade600,
      backgroundImage: hasPhoto ? NetworkImage(msg.senderPhotoUrl!) : null,
      child: !hasPhoto
          ? Text(
              msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Rechercher un message...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => searchQuery = value.trim()),
              )
            : Column(
              children: [
                const Divider(height: 5,color: Colors.amber,),
                const Text("Messages", style: TextStyle(color: Colors.white)),
              ],
            ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  _searchController.clear();
                  searchQuery = "";
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      // ignore: deprecated_member_use
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bacground.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: StreamBuilder<List<Message>>(
                stream: service.getMessages(limit: 50),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // On garde une référence aux messages "live" pour la pagination
                  liveMessages = snapshot.data!;
                  var messages = [...liveMessages, ...olderMessages];

                  if (searchQuery.isNotEmpty) {
                    messages = messages
                        .where((m) =>
                            m.text.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // On ne scrolle vers le bas que si un NOUVEAU message vient
                    // d'arriver en tête (évite de casser la pagination vers le haut)
                    final topId = messages.isNotEmpty ? messages.first.id : null;
                    final isNewMessage = topId != null && topId != _lastTopMessageId;
                    final isNearBottom = !_scrollController.hasClients ||
                        _scrollController.position.pixels <= 100;

                    if (isNewMessage && isNearBottom) {
                      scrollToBottom();
                    }
                    _lastTopMessageId = topId;
                  });

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun message trouvé",
                        style: TextStyle(
                          color: Color.fromARGB(137, 231, 224, 224),
                          fontSize: 18,

                          ),
                      ),
                    );
                  }

                  final itemCount = messages.length + (hasMoreOlder ? 1 : 0);

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      // 🔄 Dernier élément = indicateur de chargement des anciens messages
                      if (index >= messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final msg = messages[index];
                      final isMe = msg.senderId == currentUser!.uid;
                      final canDelete = isMe || role == "admin";
                      final badge = roleBadge(msg.senderRole);

                      // Regroupement des réactions : emoji -> nombre
                      final Map<String, int> reactionCounts = {};
                      for (final emoji in msg.reactions.values) {
                        reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment:
                              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              buildAvatar(msg),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: GestureDetector(
                                onLongPress: () =>
                                    showMessageOptions(context, msg, canDelete),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    badge,
                                    Container(
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

                                          // 💬 Citation du message auquel on répond
                                          if (msg.replyToId != null) ...[
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              margin: const EdgeInsets.only(bottom: 6),
                                              decoration: BoxDecoration(
                                                // ignore: deprecated_member_use
                                                color: Colors.black.withOpacity(0.06),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border(
                                                  left: BorderSide(
                                                      color: Colors.indigo.shade400,
                                                      width: 3),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    msg.replyToSender ?? "",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.indigo.shade700,
                                                    ),
                                                  ),
                                                  Text(
                                                    msg.replyToText ?? "",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 12, color: Colors.black54),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],

                                          // 📝 Texte du message
                                          if (msg.text.isNotEmpty)
                                            Text(
                                              msg.text,
                                              style: const TextStyle(
                                                  fontSize: 16, color: Colors.black87),
                                            ),

                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                formatDate(msg.timestamp),
                                                style: const TextStyle(
                                                    fontSize: 12, color: Colors.black45),
                                              ),
                                              if (isMe) ...[
                                                const SizedBox(width: 4),
                                                const Icon(Icons.done_all,
                                                    size: 14, color: Colors.blue),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ❤️ Réactions affichées sous la bulle
                                    if (reactionCounts.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                                // ignore: deprecated_member_use
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 3),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: reactionCounts.entries.map((e) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              child: Text("${e.key}${e.value}",
                                                  style: const TextStyle(fontSize: 12)),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              buildAvatar(msg),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // ⌨️ INDICATEUR "EN TRAIN D'ÉCRIRE"
          StreamBuilder<List<String>>(
            stream: service.getTypingUsers(currentUid ?? ""),
            builder: (context, snapshot) {
              final typingUsers = snapshot.data ?? [];
              if (typingUsers.isEmpty) return const SizedBox.shrink();
              final label = typingUsers.length == 1
                  ? "${typingUsers.first} est en train d'écrire..."
                  : "${typingUsers.join(', ')} sont en train d'écrire...";
              return Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              );
            },
          ),

          /// 📩 INPUT
          ChatInput(
            replyingTo: replyingTo,
            onCancelReply: () => setState(() => replyingTo = null),
            onTypingChanged: (isTyping) => service.setTyping(isTyping),
            onSend: (text) async {
              await service.sendMessage(text, replyTo: replyingTo);
              setState(() => replyingTo = null);
              scrollToBottom();
            },
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartbusudm/models/message_model.dart';
 
class ChatInput extends StatefulWidget {
  final Function(String text) onSend;
  final ValueChanged<bool>? onTypingChanged;
  final Message? replyingTo;
  final VoidCallback? onCancelReply;
 
  const ChatInput({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.replyingTo,
    this.onCancelReply,
  });
 
  @override
  State<ChatInput> createState() => _ChatInputState();
}
 
class _ChatInputState extends State<ChatInput> {
  final controller = TextEditingController();
  Timer? _typingTimer;
 
  /// ⌨️ Déclenche "en train d'écrire" puis le coupe après 3s d'inactivité
  void onTextChanged(String value) {
    widget.onTypingChanged?.call(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      widget.onTypingChanged?.call(false);
    });
  }
 
  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    controller.clear();
    _typingTimer?.cancel();
    widget.onTypingChanged?.call(false);
  }
 
  @override
  void dispose() {
    _typingTimer?.cancel();
    controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyingTo != null) _buildReplyPreview(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onTextChanged,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Écrire un message...",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Container(width: 3, height: 32, color: Colors.indigo),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Réponse à ${widget.replyingTo!.senderName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.indigo,
                  ),
                ),
                Text(
                  widget.replyingTo!.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onCancelReply,
          ),
        ],
      ),
    );
  }
}
 

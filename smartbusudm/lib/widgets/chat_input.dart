

import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;

  const ChatInput({super.key, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final controller = TextEditingController();

  void send() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Écrire un message...",
                border: OutlineInputBorder(),
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
    );
  }
}
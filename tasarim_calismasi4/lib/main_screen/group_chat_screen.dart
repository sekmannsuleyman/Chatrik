import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../constants.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel groupModel;
  const GroupChatScreen({super.key, required this.groupModel});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('gruplar')
        .doc(widget.groupModel.groupId)
        .collection('mesajlar')
        .add({
      Constants.senderUID: 'demoUID', // gerçek kullanıcı UID'si kullanılmalı
      Constants.messageType: 'text',
      Constants.messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      Constants.timeSent: Timestamp.now(),
      Constants.lastMessage: message,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupModel.groupName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('gruplar')
                  .doc(widget.groupModel.groupId)
                  .collection('mesajlar')
                  .orderBy(Constants.timeSent)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(msg[Constants.lastMessage] ?? ''),
                      subtitle: Text(msg[Constants.senderUID] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Mesaj yaz...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

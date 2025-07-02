import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../constants.dart';
import 'group_chat_screen.dart'; // Bu önemli!

class PrivateGroupScreen extends StatelessWidget {
  const PrivateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Arama filtresi eklenecekse burası kullanılabilir
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('gruplar')
                .where(Constants.isPrivate, isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Bir hata oluştu"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("Hiç özel grup yok"));
              }

              final groups = docs
                  .map((doc) => GroupModel.fromMap(doc.data() as Map<String, dynamic>))
                  .toList();

              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(group.groupImage),
                    ),
                    title: Text(group.groupName),
                    subtitle: Text(group.groupDescription),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatScreen(groupModel: group),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

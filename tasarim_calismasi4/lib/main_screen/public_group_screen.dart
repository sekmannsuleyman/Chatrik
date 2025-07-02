import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../constants.dart';

class PublicGroupScreen extends StatelessWidget {
  const PublicGroupScreen({super.key});

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
              // Arama filtreleme yapılacaksa SearchProvider ile bağlanabilir.
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('gruplar')
                .where(Constants.isPrivate, isEqualTo: false)
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
                return const Center(child: Text("Hiç herkese açık grup yok"));
              }

              final groups = docs
                  .map((doc) => GroupModel.fromMap(
                  doc.data() as Map<String, dynamic>))
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

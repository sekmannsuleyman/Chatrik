import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

import '../models/chat_model.dart';
import '../models/group_model.dart';
import '../utilities/global_methods.dart';
import '../widgets/chat_widget.dart';
import 'data_repository.dart';

class ChatsStream extends StatelessWidget {
  const ChatsStream({
    super.key,
    required this.uid,
    this.groupModel,
    this.searchQuery = '',
    this.limit = 20,
    this.isLive = true,
  });

  final String uid;
  final GroupModel? groupModel;
  final String searchQuery;
  final int limit;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: DataRepository.getChatsListQuery(userId: uid, groupModel: groupModel),
      pageSize: limit,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Bir hata oluştu"));
        }
        if (snapshot.docs.isEmpty) {
          return const Center(child: Text("Sohbet bulunamadı"));
        }

        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            final document = snapshot.docs[index];
            final (ChatModel chatModel, GroupModel? newGModel) =
            GlobalMethods.getChatData(
                documnets: document, groupModel: groupModel);

            // Arama filtresi
            if (!chatModel.name.toLowerCase().contains(searchQuery.toLowerCase())) {
              if (index == snapshot.docs.length - 1 &&
                  !snapshot.docs.any((doc) {
                    final (chatModel, newGModel) = GlobalMethods.getChatData(
                        documnets: doc, groupModel: groupModel);
                    return chatModel.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  })) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Eşleşme Bulunamadı',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            return ChatWidget(
              chatModel: chatModel,
              isGroup: groupModel != null,
              onTap: () => GlobalMethods.navigateToChatScreen(
                context: context,
                uid: uid,
                chatModel: chatModel,
                groupModel: newGModel,
              ),
            );
          },
        );
      },
    );
  }
}
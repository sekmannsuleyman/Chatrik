import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart'; // FirestoreQueryBuilder için import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../enums/enums.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../providers/search_provider.dart';
import '../streams/data_repository.dart';
import 'friend_widget.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.viewType,
    this.groupId = '',
    this.groupMembersUIDs = const [],
    this.limit = 20,
    this.isLive = true,
  });

  final FriendViewType viewType;
  final String groupId;
  final List<String> groupMembersUIDs;
  final int limit;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, SearchProvider>(
      builder: (context, authProvider, searchProvider, child) {
        final uid = authProvider.userModel!.uid;
        final searchQuery = searchProvider.searchQuery;

        return FutureBuilder<Query>(
          future: DataRepository.getFriendsQuery(
            uid: uid,
            groupID: groupId,
            viewType: viewType,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Bir şeyler yanlış gitti"));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("Veri bulunamadı"));
            }

            return FirestoreQueryBuilder(
              query: snapshot.data!,
              pageSize: limit,
              builder: (context, snapshot, _) {
                if (snapshot.isFetching) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Bir hata oluştu"));
                }
                if (snapshot.docs.isEmpty) {
                  return const Center(child: Text("Veri bulunamadı"));
                }

                return ListView.builder(
                  itemCount: snapshot.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                      snapshot.fetchMore();
                    }

                    final document = snapshot.docs[index];
                    final UserModel friend =
                    UserModel.fromMap(document.data() as Map<String, dynamic>);

                    // Arama filtresi
                    if (!friend.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase())) {
                      if (index == snapshot.docs.length - 1 &&
                          !snapshot.docs.any((doc) {
                            final UserModel user = UserModel.fromMap(
                                doc.data() as Map<String, dynamic>);
                            return user.name
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

                    // Grup üyeleri kontrolü
                    if (index == snapshot.docs.length - 1 &&
                        snapshot.docs.every((doc) {
                          final UserModel user = UserModel.fromMap(
                              doc.data() as Map<String, dynamic>);
                          return groupMembersUIDs.contains(user.uid);
                        })) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Tüm arkadaşlar zaten grupta',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    // Grup üyesi olan arkadaşları atla
                    if (groupMembersUIDs.isNotEmpty &&
                        groupMembersUIDs.contains(friend.uid)) {
                      return const SizedBox.shrink();
                    }

                    return FriendWidget(
                      friend: friend,
                      viewType: viewType,
                      groupId: groupId,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
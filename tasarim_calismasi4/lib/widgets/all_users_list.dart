import 'package:firebase_ui_firestore/firebase_ui_firestore.dart'; // FirestoreQueryBuilder için import
import 'package:flutter/material.dart';
import '../enums/enums.dart' show FriendViewType;
import '../models/user_model.dart';
import '../streams/data_repository.dart';
import 'friend_widget.dart';

class AllUsersList extends StatelessWidget {
  const AllUsersList({
    super.key,
    required this.userID,
    required this.searchQuery,
  });

  final String userID;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: DataRepository.getUsersQuery(userID: userID),
      pageSize: 20,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Bir hata oluştu"));
        }
        if (snapshot.docs.isEmpty) {
          return const Center(child: Text("Kullanıcı bulunamadı"));
        }

        return ListView.builder(
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            final document = snapshot.docs[index];
            final user = UserModel.fromMap(document.data() as Map<String, dynamic>);

            // Arama filtresi
            if (!user.name.toLowerCase().contains(searchQuery.toLowerCase())) {
              if (index == snapshot.docs.length - 1 &&
                  !snapshot.docs.any((doc) {
                    return user.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                  })) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Kullanıcı Bulunamadı',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

            // Kendi verilerimizi listeden gizle
            if (user.uid == userID) {
              return const SizedBox.shrink();
            }

            return FriendWidget(friend: user, viewType: FriendViewType.allUsers);
          },
        );
      },
    );
  }
}
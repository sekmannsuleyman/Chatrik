import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../enums/enums.dart';
import '../widgets/friends_list.dart';
import '../widgets/my_app_bar.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key, this.groupId = ''});

  final String groupId;

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('İstekler'),
        onPressed: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // cupertinosearchbar
            CupertinoSearchTextField(
              placeholder: 'Arama',
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                print(value);
              },
            ),

            Expanded(
                child: FriendsList(
              viewType: FriendViewType.friendRequests,
              groupId: widget.groupId,
            )),
          ],
        ),
      ),
    );
  }
}

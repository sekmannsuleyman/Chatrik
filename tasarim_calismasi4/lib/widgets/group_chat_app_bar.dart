import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/group_model.dart';
import '../providers/group_provider.dart';
import '../utilities/global_methods.dart';
import 'group_members.dart';

class GroupChatAppBar extends StatefulWidget {
  const GroupChatAppBar({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupChatAppBar> createState() => _GroupChatAppBarState();
}

class _GroupChatAppBarState extends State<GroupChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          context.read<GroupProvider>().groupStream(groupId: widget.groupId),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Bir şeyler ters gitti'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final groupModel =
            GroupModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return GestureDetector(
          onTap: () {
            // navigate to group information screen
            context
                .read<GroupProvider>()
                .updateGroupMembersList()
                .whenComplete(() {
              Navigator.pushNamed(context, Constants.groupInformationScreen);
            });
          },
          child: Row(
            children: [
              GlobalMethods.userImageWidget(
                imageUrl: groupModel.groupImage,
                radius: 20,
                onTap: () {
                  // navigate to group settings screen
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupModel.groupName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    GroupMembers(membersUIDs: groupModel.membersUIDs),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

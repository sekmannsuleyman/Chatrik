import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../providers/group_provider.dart';
import '../utilities/global_methods.dart';
import '../utilities/my_dialogs.dart';


class GoupMembersCard extends StatefulWidget {
  const GoupMembersCard({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  State<GoupMembersCard> createState() => _GoupMembersCardState();
}

class _GoupMembersCardState extends State<GoupMembersCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future: widget.groupProvider.getGroupMembersDataFromFirestore(
              isAdmin: false,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Bir şeyler ters gitti'),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Üye yok'),
                );
              }
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final member = snapshot.data![index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: GlobalMethods.userImageWidget(
                          imageUrl: member.image, radius: 40, onTap: () {}),
                      title: Text(member.name),
                      subtitle: Text(member.aboutMe),
                      trailing: widget.groupProvider.groupModel.adminsUIDs
                              .contains(member.uid)
                          ? const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.orangeAccent,
                            )
                          : const SizedBox(),
                      onTap: !widget.isAdmin
                          ? null
                          : () {
                              // show dialog to remove member
                              MyDialogs.showMyAnimatedDialog(
                                context: context,
                                title: 'Üyeyi kaldır',
                                content:
                                    'Kaldırmak istediğinizden emin misiniz?${member.name} gruptan?',
                                textAction: 'Remove',
                                onActionTap: (value, updatedText) async {
                                  if (value) {
                                    //remove member from group
                                    await widget.groupProvider
                                        .removeGroupMember(
                                      groupMember: member,
                                    );

                                    setState(() {});
                                  }
                                },
                              );
                            },
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../providers/group_provider.dart';
import '../utilities/my_dialogs.dart';
import '../widgets/add_members.dart';
import '../widgets/exit_group_card.dart';
import '../widgets/group_members_card.dart';
import '../widgets/info_details_card.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/settings_and_media.dart';

class GroupInformationScreen extends StatefulWidget {
  const GroupInformationScreen({super.key});

  @override
  State<GroupInformationScreen> createState() => _GroupInformationScreenState();
}

class _GroupInformationScreenState extends State<GroupInformationScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    bool isMember =
        context.read<GroupProvider>().groupModel.membersUIDs.contains(uid);
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        bool isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);

        return groupProvider.isSloading
            ? const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Fotoğraf yükleniyor, Lütfen bekleyin...')
                    ],
                  ),
                ),
              )
            : Scaffold(
                appBar: MyAppBar(
                  title: const Text('Grup Bilgisi'),
                  onPressed: () => Navigator.pop(context),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 10.0),
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InfoDetailsCard(
                        groupProvider: groupProvider,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 10),
                      SettingsAndMedia(
                        groupProvider: groupProvider,
                        isAdmin: isAdmin,
                      ),
                      const SizedBox(height: 20),
                      AddMembers(
                        groupProvider: groupProvider,
                        isAdmin: isAdmin,
                        onPressed: () {
                          groupProvider.setEmptyTemps();
                          // show  bottom sheet to add members
                          MyDialogs.showAddMembersBottomSheet(
                            context: context,
                            groupMembersUIDs:
                                groupProvider.groupModel.membersUIDs,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      isMember
                          ? Column(
                              children: [
                                GoupMembersCard(
                                  isAdmin: isAdmin,
                                  groupProvider: groupProvider,
                                ),
                                const SizedBox(height: 10),
                                ExitGroupCard(
                                  uid: uid,
                                )
                              ],
                            )
                          : const SizedBox(),
                    ],
                  )),
                ),
              );
      },
    );
  }
}

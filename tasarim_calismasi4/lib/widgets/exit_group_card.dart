import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:tasarim_calismasi4/widgets/settings_list_tile.dart';

import '../providers/group_provider.dart';
import '../utilities/global_methods.dart';
import '../utilities/my_dialogs.dart';

class ExitGroupCard extends StatelessWidget {
  const ExitGroupCard({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SettingsListTile(
          title: 'Gruptan ayrıl',
          icon: Icons.exit_to_app,
          iconContainerColor: Colors.red,
          onTap: () {
            // exit group
            MyDialogs.showMyAnimatedDialog(
              context: context,
              title: 'Gruptan ayrıl',
              content: 'Gruptan ayrılmak istediğine emin misin?',
              textAction: 'Ayrıl',
              onActionTap: (value, updatedText) async {
                if (value) {
                  // exit group
                  final groupProvider = context.read<GroupProvider>();
                  await groupProvider.exitGroup(uid: uid).whenComplete(() {
                    GlobalMethods.showSnackBar(
                        context, 'Gruptan ayrılındı');
                    // navigate to first screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}

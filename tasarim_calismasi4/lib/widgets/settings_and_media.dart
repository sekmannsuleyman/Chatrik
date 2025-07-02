import 'package:flutter/material.dart';
import 'package:tasarim_calismasi4/widgets/settings_list_tile.dart';

import '../main_screen/group_settings_screen.dart';
import '../providers/group_provider.dart';
import '../utilities/global_methods.dart';

class SettingsAndMedia extends StatelessWidget {
  const SettingsAndMedia({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            SettingsListTile(
              title: 'Medya',
              icon: Icons.image,
              iconContainerColor: Colors.deepPurple,
              onTap: () {
                // navigate to media screen
              },
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SettingsListTile(
              title: 'Grup Ayarları',
              icon: Icons.settings,
              iconContainerColor: Colors.deepPurple,
              onTap: () {
                if (!isAdmin) {
                  // show snackbar
                  GlobalMethods.showSnackBar(
                      context, 'Grup ayarlarını yalnızca yönetici değiştirebilir');
                } else {
                  groupProvider.updateGroupAdminsList().whenComplete(() {
                    // navigate to group settings screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GroupSettingsScreen(),
                      ),
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

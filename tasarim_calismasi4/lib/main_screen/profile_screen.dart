import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../utilities/my_dialogs.dart';
import '../widgets/info_details_card.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/settings_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  // get the saved theme mode
  Future<void> getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    if (mounted) {
      setState(() {
        isDarkMode = savedThemeMode == AdaptiveThemeMode.dark;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    final authProvider = context.watch<AuthenticationProvider>();
    bool isMyProfile = uid == authProvider.uid;

    return authProvider.isLoading
        ? const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Fotoğraf yükleniyor, Lütfen bekleyin...'),
          ],
        ),
      ),
    )
        : Scaffold(
      appBar: MyAppBar(
        title: const Text('Profil'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: StreamBuilder(
        stream: context
            .read<AuthenticationProvider>()
            .userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel = UserModel.fromMap(
              snapshot.data!.data() as Map<String, dynamic>);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoDetailsCard(userModel: userModel),
                  const SizedBox(height: 10),
                  if (isMyProfile)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Ayarlar',
                            style: GoogleFonts.openSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Column(
                            children: [
                              SettingsListTile(
                                title: 'Hesap',
                                icon: Icons.person,
                                iconContainerColor: Colors.deepPurple,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                              SettingsListTile(
                                title: 'Medyam',
                                icon: Icons.image,
                                iconContainerColor: Colors.green,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                              SettingsListTile(
                                title: 'Bildirimler',
                                icon: Icons.notifications,
                                iconContainerColor: Colors.red,
                                onTap: () {
                                  // open_settings kaldırıldığı için boş bırakıldı
                                  // Alternatif: Platform kanalını kullanarak manuel yönlendirme
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Column(
                            children: [
                              SettingsListTile(
                                title: 'Yardım',
                                icon: Icons.help,
                                iconContainerColor: Colors.yellow,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                              SettingsListTile(
                                title: 'Paylaş',
                                icon: Icons.share,
                                iconContainerColor: Colors.blue,
                                onTap: () {
                                  // navigate to account settings
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                            ),
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  isDarkMode
                                      ? Icons.nightlight_round
                                      : Icons.wb_sunny_rounded,
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                            title: const Text('Temayı değştir'),
                            trailing: Switch(
                              value: isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  isDarkMode = value;
                                });
                                if (value) {
                                  AdaptiveTheme.of(context).setDark();
                                } else {
                                  AdaptiveTheme.of(context).setLight();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Column(
                            children: [
                              SettingsListTile(
                                title: 'Oturumu kapat',
                                icon: Icons.logout_outlined,
                                iconContainerColor: Colors.red,
                                onTap: () {
                                  MyDialogs.showMyAnimatedDialog(
                                    context: context,
                                    title: 'Oturumu kapat',
                                    content:
                                    'Oturumu kapatmak istediğinize emin misiniz?',
                                    textAction: 'Oturumu kapat',
                                    onActionTap: (value, updatedText) {
                                      if (value) {
                                        context
                                            .read<AuthenticationProvider>()
                                            .logout()
                                            .whenComplete(() {
                                          Navigator.pop(context);
                                          Navigator
                                              .pushNamedAndRemoveUntil(
                                            context,
                                            Constants.loginScreen,
                                                (route) => false,
                                          );
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
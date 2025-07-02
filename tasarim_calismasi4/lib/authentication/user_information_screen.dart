import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../utilities/global_methods.dart';
import '../widgets/display_user_image.dart';
import '../widgets/my_app_bar.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  // final RoundedLoadingButtonController _btnController =
  //     RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    //_btnController.stop();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authentication =
        context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Kullanıcı Bilgileri'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            DisplayUserImage(
              finalFileImage: authentication.finalFileImage,
              radius: 60,
              onPressed: () {
                authentication.showBottomSheet(
                    context: context, onSuccess: () {});
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              maxLength: 20,
              decoration: const InputDecoration(
                hintText: 'Adınızı Giriniz',
                labelText: 'Adınızı Giriniz',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: MaterialButton(
                onPressed: context.read<AuthenticationProvider>().isLoading
                    ? null
                    : () {
                        if (_nameController.text.isEmpty ||
                            _nameController.text.length < 3) {
                          GlobalMethods.showSnackBar(
                              context, 'Lütfen isim giriniz');
                          return;
                        }
                        // save user data to firestore
                        saveUserDataToFireStore();
                      },
                child: context.watch<AuthenticationProvider>().isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.orangeAccent,
                      )
                    : const Text(
                        'Devam',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5),
                      ),
              ),

              // RoundedLoadingButton(
              //   controller: _btnController,
              //   onPressed: () {
              //     if (_nameController.text.isEmpty ||
              //         _nameController.text.length < 3) {
              //       showSnackBar(context, 'Please enter your name');
              //       _btnController.reset();
              //       return;
              //     }
              //     // save user data to firestore
              //     saveUserDataToFireStore();
              //   },
              //   successIcon: Icons.check,
              //   successColor: Colors.green,
              //   errorColor: Colors.red,
              //   color: Theme.of(context).primaryColor,
              //   child: const Text(
              //     'Continue',
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: 16,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ),
          ],
        ),
      )),
    );
  }

  // save user data to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Merhaba ben Chatrik kullanıyorum',
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [],
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      //fileImage: finalFileImage,
      onSuccess: () async {
        // save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();

        navigateToHomeScreen();
      },
      onFail: () async {
        GlobalMethods.showSnackBar(context, 'Kullanıcı verileri kaydedilemedi');
      },
    );
  }

  void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}

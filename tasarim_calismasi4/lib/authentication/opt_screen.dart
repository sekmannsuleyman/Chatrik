import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/authentication_provider.dart';
import '../widgets/my_app_bar.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? otpCode;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // get the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final verificationId = args[Constants.verificationId] as String;
    final phoneNumber = args[Constants.phoneNumber] as String;

    final authProvider = context.watch<AuthenticationProvider>();

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.openSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Doğrulama Kodu'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Doğrulama',
                    style: GoogleFonts.openSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    'Numaraya gönderilen 6 haneli kodu girin',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    phoneNumber,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 68,
                    child: Pinput(
                      length: 6,
                      controller: controller,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      onCompleted: (pin) {
                        setState(() {
                          otpCode = pin;
                        });
                        // verify otp code
                        verifyOTPCode(
                          verificationId: verificationId,
                          otpCode: otpCode!,
                        );
                      },
                      focusedPinTheme: defaultPinTheme.copyWith(
                        height: 68,
                        width: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      errorPinTheme: defaultPinTheme.copyWith(
                        height: 68,
                        width: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                  authProvider.isSuccessful
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : const SizedBox.shrink(),
                  authProvider.isLoading
                      ? const SizedBox.shrink()
                      : Text(
                          'Kodu almadınız mı?',
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                  const SizedBox(height: 10),
                  authProvider.isLoading
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: authProvider.secondsRemaing == 0
                              ? () {
                                  // reset the code to send again
                                  authProvider.resendCode(
                                    context: context,
                                    phone: phoneNumber,
                                  );
                                }
                              : null,
                          child: Text(
                            'Kodu Yeniden Gönder',
                            style: GoogleFonts.openSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTPCode({
    required String verificationId,
    required String otpCode,
  }) async {
    final authProvider = context.read<AuthenticationProvider>();
    authProvider.verifyOTPCode(
      verificationId: verificationId,
      otpCode: otpCode,
      context: context,
      onSuccess: () async {
        // 1. check if user exists in firestore
        bool userExists = await authProvider.checkUserExists();

        if (userExists) {
          // 2. if user exists,

          // * get user information from firestore
          await authProvider.getUserDataFromFireStore();

          // * save user information to provider / shared preferences
          await authProvider.saveUserDataToSharedPreferences();

          // * navigate to home screen
          navigate(userExits: true);
        } else {
          // 3. if user doesn't exist, navigate to user information screen
          navigate(userExits: false);
        }
      },
    );
  }

  void navigate({required bool userExits}) {
    if (userExits) {
      // navigate to home and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        Constants.homeScreen,
        (route) => false,
      );
    } else {
      // navigate to user information screen
      Navigator.pushNamed(
        context,
        Constants.userInformationScreen,
      );
    }
  }
}

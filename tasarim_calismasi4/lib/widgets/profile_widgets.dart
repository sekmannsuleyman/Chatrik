import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../main_screen/friend_requests_screen.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../providers/group_provider.dart';
import '../utilities/global_methods.dart';
import '../utilities/my_dialogs.dart';

class GroupStatusWidget extends StatelessWidget {
  const GroupStatusWidget({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin;
  final GroupProvider groupProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: !isAdmin
              ? null
              : () {
                  // show dialog to change group type
                  MyDialogs.showMyAnimatedDialog(
                    context: context,
                    title: 'Grup Türünü Değiştir',
                    content:
                        'Grup türünü şu şekilde değiştirmek istediğinizden emin misiniz: ${groupProvider.groupModel.isPrivate ? 'Açık' : 'Gizli'}?',
                    textAction: 'Change',
                    onActionTap: (value, updatedText) {
                      if (value) {
                        // change group type
                        groupProvider.changeGroupType();
                      }
                    },
                  );
                },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.deepPurple : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              groupProvider.groupModel.isPrivate ? 'Gizli' : 'Açık',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GetRequestWidget(
          groupProvider: groupProvider,
          isAdmin: isAdmin,
        ),
      ],
    );
  }
}

class ProfileStatusWidget extends StatelessWidget {
  const ProfileStatusWidget({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FriendsButton(
            currentUser: currentUser,
            userModel: userModel,
          ),
          const SizedBox(width: 10),
          FriendRequestButton(
            currentUser: currentUser,
            userModel: userModel,
          ),
        ],
      ),
    );
  }
}

class FriendsButton extends StatelessWidget {
  const FriendsButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    // friends button
    Widget buildFriendsButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendsUIDs.isNotEmpty) {
        return MyElevatedButton(
          onPressed: () {
            // navigate to friends screen
            Navigator.pushNamed(
              context,
              Constants.friendsScreen,
            );
          },
          label: 'Arkadaşlar',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        if (currentUser.uid != userModel.uid) {
          // show cancle friend request button if the user sent us friend request
          // else show send friend request button
          if (userModel.friendRequestsUIDs.contains(currentUser.uid)) {
            // show send friend request button
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .cancleFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  GlobalMethods.showSnackBar(
                      context, 'arkadaşlık isteği iptal edildi');
                });
              },
              label: 'İsteği İptal Ett',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.sentFriendRequestsUIDs
              .contains(currentUser.uid)) {
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  GlobalMethods.showSnackBar(
                      context, 'Artık arkadaşsınız ${userModel.name}');
                });
              },
              label: 'Arkadaşı ekle',
              width: MediaQuery.of(context).size.width * 0.4,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyElevatedButton(
                  onPressed: () async {
                    // show unfriend dialog to ask the user if he is sure to unfriend
                    // create a dialog to confirm logout
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Arkadaşlıktan çıkar',
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          'Arkadaşlıktan çıkmak istediğinden emin misin?${userModel.name}?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // remove friend
                              await context
                                  .read<AuthenticationProvider>()
                                  .removeFriend(friendID: userModel.uid)
                                  .whenComplete(() {
                                GlobalMethods.showSnackBar(
                                    context, 'Artık arkadaş değilsiniz');
                              });
                            },
                            child: const Text('Evet'),
                          ),
                        ],
                      ),
                    );
                  },
                  label: 'Arkadaşlıktan çıkar',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Colors.deepPurple,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 10),
                MyElevatedButton(
                  onPressed: () async {
                    // navigate to chat screen
                    // navigate to chat screen with the folowing arguments
                    // 1. friend uid 2. friend name 3. friend image 4. groupId with an empty string
                    Navigator.pushNamed(context, Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: userModel.uid,
                          Constants.contactName: userModel.name,
                          Constants.contactImage: userModel.image,
                          Constants.groupId: ''
                        });
                  },
                  label: 'Sohbet',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          } else {
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .sendFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  GlobalMethods.showSnackBar(context, 'arkadaşlık isteği gönderildi');
                });
              },
              label: 'İstek Gönder',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      }
    }

    return buildFriendsButton();
  }
}

class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel;
  final UserModel currentUser;

  @override
  Widget build(BuildContext context) {
    // friend request button
    Widget buildFriendRequestButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendRequestsUIDs.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.orangeAccent,
            child: IconButton(
              onPressed: () {
                // navigate to friend requests screen
                Navigator.pushNamed(
                  context,
                  Constants.friendRequestsScreen,
                );
              },
              icon: const Icon(
                Icons.person_add,
                color: Colors.black,
              ),
            ),
          ),
        );
      } else {
        // not in our profile
        return const SizedBox.shrink();
      }
    }

    return buildFriendRequestButton();
  }
}

class GetRequestWidget extends StatelessWidget {
  const GetRequestWidget({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    // get requestWidget
    Widget getRequestWidget() {
      // check if user is admin
      if (isAdmin) {
        // chec if there is any request
        if (groupProvider.groupModel.awaitingApprovalUIDs.isNotEmpty) {
          return InkWell(
            onTap: () {
              // navigate to add members screen
              // navigate to friend requests screen
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FriendRequestScreen(
                  groupId: groupProvider.groupModel.groupId,
                );
              }));
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orangeAccent,
              child: Icon(
                Icons.person_add,
                color: Colors.white,
                size: 15,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      } else {
        return const SizedBox();
      }
    }

    return getRequestWidget();
  }
}

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.textColor,
  });

  final VoidCallback onPressed;
  final String label;
  final double width;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Widget buildElevatedButton() {
      return SizedBox(
        //width: width,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return buildElevatedButton();
  }
}

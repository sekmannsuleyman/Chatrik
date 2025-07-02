import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../constants.dart';
import '../enums/enums.dart';
import '../models/chat_model.dart';
import '../models/group_model.dart';
import '../models/last_message_model.dart';
import '../providers/group_provider.dart';
import 'assets_manager.dart' show AssetsMenager;
import 'my_dialogs.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class GlobalMethods {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  static Widget userImageWidget({
    required String imageUrl,
    File? fileImage,
    required double radius,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage: getImageToShow(
            imageUrl: imageUrl,
            fileImage: fileImage,
          )),
    );
  }

  static getImageToShow({
    required String imageUrl,
    required File? fileImage,
  }) {
    return fileImage != null
        ? FileImage(File(fileImage.path)) as ImageProvider
        : imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : const AssetImage(AssetsMenager.userImage);
  }

// picp image from gallery or camera
  static Future<File?> pickImage({
    required bool fromCamera,
    required Function(String) onFail,
  }) async {
    File? fileImage;
    if (fromCamera) {
      // get picture from camera
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile == null) {
          onFail('Resim seçilmedi');
        } else {
          fileImage = File(pickedFile.path);
        }
      } catch (e) {
        onFail(e.toString());
      }
    } else {
      // get picture from gallery
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile == null) {
          onFail('Resim seçilmedi');
        } else {
          fileImage = File(pickedFile.path);
        }
      } catch (e) {
        onFail(e.toString());
      }
    }

    return fileImage;
  }

// pick video from gallery
  static Future<File?> pickVideo({
    required Function(String) onFail,
  }) async {
    File? fileVideo;
    try {
      final pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile == null) {
        onFail('Video seçilmedi');
      } else {
        fileVideo = File(pickedFile.path);
      }
    } catch (e) {
      onFail(e.toString());
    }

    return fileVideo;
  }

  static Center buildDateTime(groupedByValue) {
    return Center(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            formatDate(groupedByValue.timeSent, [dd, ' ', M, ', ', yyyy]),
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static Widget messageToShow(
      {required MessageEnum type, required String message}) {
    switch (type) {
      case MessageEnum.text:
        return Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      case MessageEnum.image:
        return const Row(
          children: [
            Icon(Icons.image_outlined),
            SizedBox(width: 10),
            Text(
              'Resim',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case MessageEnum.video:
        return const Row(
          children: [
            Icon(Icons.video_library_outlined),
            SizedBox(width: 10),
            Text(
              'Video',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case MessageEnum.audio:
        return const Row(
          children: [
            Icon(Icons.audiotrack_outlined),
            SizedBox(width: 10),
            Text(
              'Ses',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      default:
        return Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

// store file to storage and return file url
  static Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask =
        FirebaseStorage.instance.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  static (ChatModel, GroupModel?) getChatData({
    required DocumentSnapshot<Object?> documnets,
    GroupModel? groupModel,
  }) {
    if (groupModel == null) {
      LastMessageModel chat =
          LastMessageModel.fromMap(documnets.data() as Map<String, dynamic>);
      final dateTime = formatDate(chat.timeSent, [hh, ':', nn, ' ', am]);
      final senderUID = chat.senderUID;
      final messageType = chat.messageType;

      ChatModel chatModel = ChatModel(
        name: chat.contactName,
        lastMessage: chat.message,
        senderUID: senderUID,
        contactUID: chat.contactUID,
        image: chat.contactImage,
        messageType: messageType,
        timeSent: dateTime,
      );
      return (chatModel, null);
    } else {
      GroupModel chat =
          GroupModel.fromMap(documnets.data() as Map<String, dynamic>);
      final dateTime = formatDate(chat.timeSent, [hh, ':', nn, ' ', am]);
      final senderUID = chat.senderUID;
      final messageType = chat.messageType;
      ChatModel chatModel = ChatModel(
        name: chat.groupName,
        lastMessage: chat.lastMessage,
        senderUID: senderUID,
        contactUID: chat.groupId,
        image: chat.groupImage,
        messageType: messageType,
        timeSent: dateTime,
      );

      return (chatModel, chat);
    }
  }

// Navigate to chat screeen
  static void navigateToChatScreen({
    required BuildContext context,
    required String uid,
    required ChatModel chatModel,
    GroupModel? groupModel,
  }) {
    if (groupModel == null) {
      _navigateToPersonalChat(context, chatModel);
      return;
    }

    _handleGroupNavigation(context, uid, groupModel);
  }

  static void _navigateToPersonalChat(
      BuildContext context, ChatModel chatModel) {
    Navigator.pushNamed(
      context,
      Constants.chatScreen,
      arguments: {
        Constants.contactUID: chatModel.contactUID,
        Constants.contactName: chatModel.name,
        Constants.contactImage: chatModel.image,
        Constants.groupId: '',
      },
    );
  }

  static void _handleGroupNavigation(
      BuildContext context, String uid, GroupModel groupModel) {
    if (groupModel.isPrivate) {
      _navigateToGroupChat(context, groupModel);
      return;
    }

    if (groupModel.membersUIDs.contains(uid)) {
      _navigateToGroupChat(context, groupModel);
      return;
    }

    if (groupModel.requestToJoing) {
      _handleJoinRequest(context, uid, groupModel);
      return;
    }

    _navigateToGroupChat(context, groupModel);
  }

  static void _navigateToGroupChat(
      BuildContext context, GroupModel groupModel) {
    context
        .read<GroupProvider>()
        .setGroupModel(groupModel: groupModel)
        .whenComplete(() {
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Constants.chatScreen,
          arguments: {
            Constants.contactUID: groupModel.groupId,
            Constants.contactName: groupModel.groupName,
            Constants.contactImage: groupModel.groupImage,
            Constants.groupId: groupModel.groupId,
          },
        );
      }
    });
  }

  static void _handleJoinRequest(
      BuildContext context, String uid, GroupModel groupModel) {
    if (groupModel.awaitingApprovalUIDs.contains(uid)) {
      GlobalMethods.showSnackBar(context, 'İstek zaten gönderildi');
      return;
    }

    MyDialogs.showMyAnimatedDialog(
      context: context,
      title: 'Katılma isteği',
      content:
          'Grup içeriğini görüntüleyebilmeniz için önce bu gruba katılma isteğinde bulunmanız gerekir',
      textAction: 'Request to join',
      onActionTap: (value, updatedText) async {
        if (!value) return;

        await context
            .read<GroupProvider>()
            .sendRequestToJoinGroup(
              groupId: groupModel.groupId,
              uid: uid,
              groupName: groupModel.groupName,
              groupImage: groupModel.groupImage,
            )
            .whenComplete(() {
          if (context.mounted) {
            GlobalMethods.showSnackBar(context, 'İstek gönder');
          }
        });
      },
    );
  }

  // is same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // format date
  static String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (isSameDay(date, today)) {
      return 'Bugun';
    } else if (isSameDay(date, yesterday)) {
      return 'Dün';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }
}

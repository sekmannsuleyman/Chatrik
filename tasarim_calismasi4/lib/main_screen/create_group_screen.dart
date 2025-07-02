import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../enums/enums.dart';
import '../models/group_model.dart';
import '../providers/authentication_provider.dart';
import '../providers/group_provider.dart';
import '../providers/search_provider.dart';
import '../utilities/global_methods.dart';
import '../widgets/display_user_image.dart';
import '../widgets/friends_list.dart';
import '../widgets/group_type_list_tile.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/settings_list_tile.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  // group name controller
  final TextEditingController groupNameController = TextEditingController();
  // group description controller
  final TextEditingController groupDescriptionController =
      TextEditingController();
  File? finalFileImage;
  String userImage = '';

  void selectImage(bool fromCamera) async {
    finalFileImage = await GlobalMethods.pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        GlobalMethods.showSnackBar(context, message);
      },
    );

    // crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Galeri'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    super.dispose();
  }

  GroupType groupValue = GroupType.private;

  // create group
  void createGroup() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final groupProvider = context.read<GroupProvider>();
    // check if the group name is empty
    if (groupNameController.text.isEmpty) {
      GlobalMethods.showSnackBar(context, 'Lütfen grup adı giriniz');
      return;
    }

    // name is less than 3 characters
    if (groupNameController.text.length < 3) {
      GlobalMethods.showSnackBar(
          context, 'Grup adı en az 3 karakterden oluşmalıdır');
      return;
    }

    // check if the group description is empty
    if (groupDescriptionController.text.isEmpty) {
      GlobalMethods.showSnackBar(context, 'Grup tanımlaması yapınız');
      return;
    }

    GroupModel groupModel = GroupModel(
      creatorUID: uid,
      groupName: groupNameController.text,
      groupDescription: groupDescriptionController.text,
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: groupValue == GroupType.private ? true : false,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoing: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );

    // create group
    groupProvider.createGroup(
      newGroupModel: groupModel,
      fileImage: finalFileImage,
      onSuccess: () {
        GlobalMethods.showSnackBar(context, 'Grup başarıyla oluşturuldu');
        Navigator.pop(context);
      },
      onFail: (error) {
        GlobalMethods.showSnackBar(context, error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: const Text('Grup oluştur'),
        onPressed: () => Navigator.pop(context),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: context.watch<GroupProvider>().isSloading
                  ? const CircularProgressIndicator()
                  : IconButton(
                      onPressed: () {
                        // create group
                        createGroup();
                      },
                      icon: const Icon(Icons.check)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DisplayUserImage(
                    finalFileImage: finalFileImage,
                    radius: 60,
                    onPressed: () {
                      showBottomSheet();
                    },
                  ),
                  const SizedBox(width: 10),
                  buildGroupType(),
                ],
              ),

              // texField for group name
              TextField(
                controller: groupNameController,
                maxLength: 25,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Grup adı',
                  label: Text('Grup adı'),
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              // textField for group description
              TextField(
                controller: groupDescriptionController,
                maxLength: 100,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Grup açıklaması ',
                  label: Text('Grup açıklaması'),
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: SettingsListTile(
                      title: 'Grup ayarları',
                      icon: Icons.settings,
                      iconContainerColor: Colors.deepPurple,
                      onTap: () {
                        // navigate to group settings screen
                        Navigator.pushNamed(
                            context, Constants.groupSettingsScreen);
                      }),
                ),
              ),

              const Text(
                'Grup üyelerini seçin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Search bar
              SearchBarWidget(
                onChanged: (value) {
                  context.read<SearchProvider>().setSearchQuery(value);
                },
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.3, // Adjest the height as needed
                child: const FriendsList(
                  viewType: FriendViewType.groupView,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildGroupType() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.private.name,
            value: GroupType.private,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: GroupTypeListTile(
            title: GroupType.public.name,
            value: GroupType.public,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ),
      ],
    );
  }
}

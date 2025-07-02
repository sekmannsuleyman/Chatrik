import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart'; // FirestoreQueryBuilder için import
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../models/message_reply_model.dart';
import '../providers/authentication_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/group_provider.dart';
import '../streams/data_repository.dart';
import '../utilities/global_methods.dart';
import '../utilities/my_dialogs.dart';
import 'align_message_left_widget.dart';
import 'align_message_right_widget.dart';
import 'date_widget.dart';
import 'message_widget.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupId,
  });

  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    if (_scrollController.hasClients) _scrollController.dispose();
    super.dispose();
  }

  void onContextMenyClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );
        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;
      case 'Kopyala':
        Clipboard.setData(ClipboardData(text: message.message));
        GlobalMethods.showSnackBar(context, 'Mesaj panoya kopyalandı');
        break;
      case 'Sil':
        final currentUserId =
            context.read<AuthenticationProvider>().userModel!.uid;
        final groupProvider = context.read<GroupProvider>();
        if (widget.groupId.isNotEmpty) {
          if (groupProvider.isSenderOrAdmin(
              message: message, uid: currentUserId)) {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: true,
            );
            return;
          } else {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: false,
            );
            return;
          }
        }
        showDeletBottomSheet(
          message: message,
          currentUserId: currentUserId,
          isSenderOrAdmin: true,
        );
        break;
    }
  }

  void showDeletBottomSheet({
    required MessageModel message,
    required String currentUserId,
    required bool isSenderOrAdmin,
  }) {
    MyDialogs.deletionBottomSheet(
      context: context,
      message: message,
      currentUserId: currentUserId,
      isSenderOrAdmin: isSenderOrAdmin,
      contactUID: widget.contactUID,
      groupId: widget.groupId,
    );
  }

  void sendReactionToMessage(
      {required String reaction, required String messageId}) {
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;
    context.read<ChatProvider>().sendReactionToMessage(
      senderUID: senderUID,
      contactUID: widget.contactUID,
      messageId: messageId,
      reaction: reaction,
      groupId: widget.groupId.isNotEmpty,
    );
  }

  void showEmojiContainer({required String messageId}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            sendReactionToMessage(
              reaction: emoji.emoji,
              messageId: messageId,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return FirestoreQueryBuilder(
      query: DataRepository.getMessagesQuery(
        userId: uid,
        contactUID: widget.contactUID,
        isGroup: widget.groupId.isNotEmpty,
      ),
      pageSize: 20,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Bir hata oluştu"));
        }
        if (snapshot.docs.isEmpty) {
          return Center(
            child: Text(
              'Sohbet başlat',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }

            final message = MessageModel.fromMap(
                snapshot.docs[index].data() as Map<String, dynamic>);
            final isMe = message.senderUID == uid;

            if (message.deletedBy.contains(uid)) {
              return const SizedBox.shrink();
            }

            Widget? dateHeader;
            if (index < snapshot.docs.length - 1) {
              final nextMessage = MessageModel.fromMap(
                  snapshot.docs[index + 1].data() as Map<String, dynamic>);
              if (!GlobalMethods.isSameDay(
                message.timeSent,
                nextMessage.timeSent,
              )) {
                dateHeader = DateWidget(message: message);
              }
            } else if (index == snapshot.docs.length - 1) {
              dateHeader = DateWidget(message: message);
            }

            final chatProvider = context.read<ChatProvider>();
            if (widget.groupId.isNotEmpty) {
              chatProvider.setMessageStatus(
                currentUserId: uid,
                contactUID: widget.contactUID,
                messageId: message.messageId,
                isSeenByList: message.isSeenBy,
                isGroupChat: widget.groupId.isNotEmpty,
              );
            } else {
              if (!message.isSeen && message.senderUID != uid) {
                chatProvider.setMessageStatus(
                  currentUserId: uid,
                  contactUID: widget.contactUID,
                  messageId: message.messageId,
                  isSeenByList: message.isSeenBy,
                  isGroupChat: widget.groupId.isNotEmpty,
                );
              }
            }

            return Column(
              children: [
                if (dateHeader != null) dateHeader,
                GestureDetector(
                  onLongPress: () async {
                    Navigator.of(context).push(
                      HeroDialogRoute(builder: (context) {
                        return ReactionsDialogWidget(
                          id: message.messageId,
                          messageWidget: isMe
                              ? AlignMessageRightWidget(
                            message: message,
                            viewOnly: true,
                            isGroupChat: widget.groupId.isNotEmpty,
                          )
                              : AlignMessageLeftWidget(
                            message: message,
                            viewOnly: true,
                            isGroupChat: widget.groupId.isNotEmpty,
                          ),
                          onReactionTap: (reaction) {
                            if (reaction == '➕') {
                              showEmojiContainer(
                                messageId: message.messageId,
                              );
                            } else {
                              sendReactionToMessage(
                                reaction: reaction,
                                messageId: message.messageId,
                              );
                            }
                          },
                          onContextMenuTap: (item) {
                            onContextMenyClicked(
                              item: item.label,
                              message: message,
                            );
                          },
                          widgetAlignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                        );
                      }),
                    );
                  },
                  child: Hero(
                    tag: message.messageId,
                    child: MessageWidget(
                      message: message,
                      onRightSwipe: () {
                        final messageReply = MessageReplyModel(
                          message: message.message,
                          senderUID: message.senderUID,
                          senderName: message.senderName,
                          senderImage: message.senderImage,
                          messageType: message.messageType,
                          isMe: isMe,
                        );
                        context
                            .read<ChatProvider>()
                            .setMessageReplyModel(messageReply);
                      },
                      isMe: isMe,
                      isGroupChat: widget.groupId.isNotEmpty,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../enums/enums.dart';
import '../models/message_model.dart';
import '../models/message_reply_model.dart';
import '../providers/chat_provider.dart';
import '../utilities/global_methods.dart';
import 'display_message_type.dart';

class MessageReplyPreview extends StatelessWidget {
  const MessageReplyPreview({
    super.key,
    this.replyMessageModel,
    this.message,
    this.viewOnly = false,
    required this.isGroupChat,
  });

  final MessageReplyModel? replyMessageModel;
  final MessageModel? message;
  final bool viewOnly;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    final type = replyMessageModel != null
        ? replyMessageModel!.messageType
        : message!.messageType;
    final chatProvider = context.read<ChatProvider>();

    final intrisitPadding = replyMessageModel != null
        ? const EdgeInsets.all(10)
        : const EdgeInsets.only(top: 5, right: 5, bottom: 5);

    final decorationColor = replyMessageModel != null
        ? Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1)
        : Theme.of(context).primaryColorDark.withOpacity(0.2);
    return IntrinsicHeight(
      child: Container(
        padding: intrisitPadding,
        decoration: BoxDecoration(
          color: decorationColor,
          borderRadius: replyMessageModel != null
              ? BorderRadius.circular(20)
              : BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            buildNameAndMessage(type),
            replyMessageModel != null ? const Spacer() : const SizedBox(),
            replyMessageModel != null
                ? closeButton(chatProvider, context)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  InkWell closeButton(ChatProvider chatProvider, BuildContext context) {
    return InkWell(
      onTap: () {
        chatProvider.setMessageReplyModel(null);
      },
      child: Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).textTheme.titleLarge!.color!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Theme.of(context).textTheme.titleLarge!.color!,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: const Icon(Icons.close)),
    );
  }

  Column buildNameAndMessage(MessageEnum type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(),
        const SizedBox(height: 5),
        replyMessageModel != null
            ? GlobalMethods.messageToShow(
                type: type,
                message: replyMessageModel!.message,
              )
            : DisplayMessageType(
                message: MessageModel(
                  senderUID: '',
                  senderName: '',
                  senderImage: '',
                  contactUID: '',
                  message: message!.repliedMessage,
                  messageType: message!.repliedMessageType,
                  timeSent: DateTime.now(),
                  messageId: '',
                  isSeen: false,
                  repliedMessage: '',
                  repliedTo: '',
                  repliedMessageType: MessageEnum.text,
                  reactions: [],
                  isSeenBy: [],
                  deletedBy: [],
                ),
                isGroupChat: isGroupChat,
                color: Colors.white,
                isReply: true,
                maxLines: 1,
                overFlow: TextOverflow.ellipsis,
                viewOnly: viewOnly,
              ),
      ],
    );
  }

  Widget getTitle() {
    if (replyMessageModel != null) {
      bool isMe = replyMessageModel!.isMe;
      return Text(
        isMe ? 'You' : replyMessageModel!.senderName,
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          //fontSize: 12,
        ),
      );
    } else {
      return Text(
        message!.repliedTo,
        style: GoogleFonts.openSans(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          //fontSize: 12,
        ),
      );
    }
  }
}

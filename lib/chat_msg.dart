import 'package:flutter/material.dart';

import 'chat_model.dart';

class ChatMsg extends StatelessWidget {
  const ChatMsg({
    Key? key,
    required this.text,
    required this.type,
  }) : super(key: key);

  final String text;
  final MsgType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: type == MsgType.bot ? Colors.green : Colors.white,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16))),
        child: Text(
          text,
          style: TextStyle(
              color: type == MsgType.user ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}

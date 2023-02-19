enum MsgType { user, bot }

class ChatModel {

  ChatModel({required this.msgType, required this.text});

  String? text;
  MsgType? msgType;
}

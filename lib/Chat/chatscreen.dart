import './ChatRoom.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final List<String> users;

  ChatScreen({this.users});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Chat Room'),
        ),
        body: ChatRoom(
          users: users,
        ));
  }
}

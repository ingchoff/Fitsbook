import './ChatRoom.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Chat Room'),
        ),
        body: ChatRoom(
          users: [
            'MaqqJx6JxvNAQy5nPWe2CEiahOl1',
            'qgp801RgwGZgVgHsGiabeo0axmM2'
          ],
        ));
  }
}

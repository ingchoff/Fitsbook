import 'package:flutter/material.dart';
import '../Profile/ProfilePic.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final String msgId;
  final String name;
  final String path;
  final String userId;
  final bool isOwner;

  ChatMessage(
      {this.text, this.msgId, this.name, this.path, this.userId, this.isOwner});

  Widget createMessage() {
    MainAxisAlignment axis = MainAxisAlignment.start;
    EdgeInsets edge = EdgeInsets.only(right: 16.0);
    dynamic first;
    dynamic sec;

    if (isOwner) {
      axis = MainAxisAlignment.end;
      edge = EdgeInsets.only(left: 16.0);

      first = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name),
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: Text(text),
          )
        ],
      );

      sec = Container(
        margin: edge,
        child: ProfilePics(
          path: path,
          diameter: 40,
        ),
      );
    } else {
      sec = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name),
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: Text(text),
          )
        ],
      );

      first = Container(
        margin: edge,
        child: ProfilePics(
          path: path,
          diameter: 40,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: axis,
      children: <Widget>[first, sec],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: createMessage(),
    );
  }
}

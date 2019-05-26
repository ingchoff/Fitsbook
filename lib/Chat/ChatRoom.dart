import './ChatMessage.dart';
import '../FileProvider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom extends StatefulWidget {
  final List<String> users;

  ChatRoom({this.users});

  @override
  State<StatefulWidget> createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  bool isFinish = false;
  final TextEditingController _textController = TextEditingController();
  List<ChatMessage> _messages = <ChatMessage>[];
  Map<String, String> _profileMap = {};
  Map<String, String> _nameMap = {};
  String ownerName = '';
  String path;
  String chatroomName = '';
  String _uid = '';

  @override
  void initState() {
    super.initState();
    initChat();
  }

  Future initChat() async {
    List<ChatMessage> msgBuffer = [];

    String uid = await FileProvider.readFile('userId');
    _uid = uid;
    DocumentSnapshot doc =
        await Firestore.instance.collection('users').document(uid).get();

    ownerName = doc.data['dname'];
    path = doc.data['profile'];
    _profileMap[uid] = doc.data['profile'];

    for (String user in widget.users) {
      DocumentSnapshot userDoc =
          await Firestore.instance.collection('users').document(user).get();
      _profileMap[userDoc.documentID] = userDoc.data['profile'];
      _nameMap[userDoc.documentID] = userDoc.data['dname'];
    }

    CollectionReference refs = Firestore.instance.collection('chats');
    QuerySnapshot docs =
        await refs.where('users', isEqualTo: widget.users).getDocuments();

    if (docs.documents.length == 0) {
      refs.document().setData({'users': widget.users});
      docs = await refs.where('users', isEqualTo: widget.users).getDocuments();
    }

    chatroomName = docs.documents[0].documentID;

    _listenerOpen();

    setState(() {
      // _messages = msgBuffer;
      isFinish = true;
    });
    
  }

  void _listenerOpen() {
    Firestore.instance
        .collection('chats')
        .document(chatroomName)
        .collection('messages')
        .orderBy('dateCreated')
        .snapshots()
        .listen((data) => data.documents.forEach((doc) {
              List<ChatMessage> duplicate = _messages
                  .where((ChatMessage chat) => chat.msgId == doc.documentID).toList();

              if (duplicate.length == 0) {
                setState(() {
                  _messages.insert(
                      0,
                      ChatMessage(
                        text: doc.data['message'],
                        msgId: doc.documentID,
                        userId: doc.data['user'],
                        isOwner: _uid == doc.data['user'] ? true : false,
                        path: _profileMap[doc.data['user']],
                        name: _nameMap[doc.data['user']],
                      ));
                });
              }
            }));
  }

  void _handleSubmitted(String text) {
    _textController.clear();

    Firestore.instance
        .collection('chats')
        .document(chatroomName)
        .collection('messages')
        .document()
        .setData({
      'message': text,
      'dateCreated': DateTime.now().millisecondsSinceEpoch,
      'user': _uid
    });
  }

  Widget _textComposerWidget() {
    return IconTheme(
        data: IconThemeData(color: Colors.green),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  decoration:
                      InputDecoration.collapsed(hintText: "Send a message"),
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (!isFinish) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemBuilder: (BuildContext _, int index) => _messages[index],
            reverse: true,
            itemCount: _messages.length,
          ),
        ),
        Divider(
          height: 1.0,
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _textComposerWidget(),
        )
      ],
    );
  }
}
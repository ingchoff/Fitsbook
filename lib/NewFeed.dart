import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class NewFeed extends StatefulWidget {
  final String uid;
  NewFeed({this.uid});
  
  @override
  State<StatefulWidget> createState() {
    return _NewFeedState();
  }
}

class _NewFeedState extends State<NewFeed> {

  String _txt;
  String _uid;

  @override
  void initState() {
    _uid = widget.uid;
    if (_uid == null) {
      // ตรวจว่ามี props user id เข้ามาไหม ถ้าไม่มีให้ไปดึง user id ของเจ้าของ
      _uid = '';
      readFile('userId').then((String userId) {
        setState(() {
          _uid = userId;
        });
      });
    }
    if (_txt == null) {
      // ตรวจว่ามี props user id เข้ามาไหม ถ้าไม่มีให้ไปดึง user id ของเจ้าของ
      _txt = '';
      readFile('email').then((String userId) {
        setState(() {
          _txt = userId;
        });
      });
    }
    super.initState();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/data.txt');
  }
  Future<String> readFile(String key) async {
    try {
      final file = await _localFile;
      // Read the file
      Map contents = json.decode(await file.readAsString());
      print(contents); // พิม data ในรูปแบบ json บน console
      print(contents[key]); // พิม data ตาม key ที่เราใส่เข้าไปในรูปแบบ string บน console
      return contents[key]; //ส่งค่ากลับ ตาม key ที่เราใส่เข้าไปในรูปแบบ string
    } catch (e) {
      print(e);
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MainPage')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Column(
            children: <Widget>[
              Text('Account Info:' + _txt),
              Text('userid:' + _uid)
            ],
          ),
        )
        
      ),
    );
  }
}
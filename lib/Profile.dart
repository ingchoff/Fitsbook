import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  final String uid;

  // constructor optional ไม่ใส่ก็ได้ ใส่ uid ของ user จะแสดง user profile ตามนั้น
  Profile({this.uid});

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
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
      return contents[key];
    } catch (e) {
      print(e);
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text(_uid),
      ),
    );
  }
}

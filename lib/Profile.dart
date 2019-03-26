import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, dynamic> _userProfile;

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
        // ดึงข้อมูล user คนนั้นจาก firestore
        Firestore.instance.collection('users').document(_uid).get().then((doc) {
          setState(() {
            _userProfile = doc.data;
          });
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

  Widget _buildProfileImage() {
    // เอาไว้สร้างรูปโปรไฟล์
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        width: 140,
        height: 140,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(_userProfile['profile']),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(80.0)),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
        color: Colors.black, fontSize: 28.0, fontWeight: FontWeight.w700);
    return Column(
      children: <Widget>[
        Text(
          _userProfile['dname'],
          style: _nameTextStyle,
        ),
        Text(_userProfile['fname'] + ' ' + _userProfile['lname'])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _userProfile == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                _buildProfileImage(),
                _buildFullName(),
              ],
            ),
    );
  }
}

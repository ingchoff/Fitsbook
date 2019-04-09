import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import './Profile/Post.dart';
import './Profile/ProfilePic.dart';

class Profile extends StatefulWidget {
  final String uid;

  // constructor optional ไม่ใส่ก็ได้ ใส่ uid ของ user จะแสดง user profile ตามนั้น
  Profile([this.uid]);

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  bool _isOwner = false;
  String _uid;
  Map<String, dynamic> _userProfile;
  Map<dynamic, dynamic> _posts = {};
  bool isFinish = false;

  @override
  void initState() {
    _uid = widget.uid;
    if (_uid == null) {
      // ตรวจว่ามี props user id เข้ามาไหม ถ้าไม่มีให้ไปดึง user id ของเจ้าของ
      _uid = '';
      readFile('userId').then((String userId) {
        setState(() {
          _uid = userId;
          _isOwner = true;
        });
        // ดึงข้อมูล user คนนั้นจาก firestore
        Firestore.instance.collection('users').document(_uid).get().then((doc) {
          setState(() {
            _userProfile = doc.data;
          });
          _getPosts(_uid).then((Map res) {
            setState(() {
              isFinish = true;
            });
          });
        });
      });
    } else {
      Firestore.instance.collection('users').document(_uid).get().then((doc) {
        setState(() {
          _userProfile = doc.data;
        });
        _getPosts(_uid).then((Map res) {
          setState(() {
            isFinish = true;
          });
        });
      });
    }
    super.initState();
  }

  Future<Map> _getPosts(String uid) async {
    Map<dynamic, dynamic> posts = {};

    QuerySnapshot doc = await Firestore.instance
        .collection('posts')
        .where('user', isEqualTo: uid)
        .orderBy('dateCreated', descending: true)
        .getDocuments();
    doc.documents.forEach((DocumentSnapshot f) {
      posts[f.documentID] = f.data;
    });
    setState(() {
      _posts = posts;
    });
    return posts;
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
    List<Widget> _list = _userProfile == null
        ? null
        : [
            ProfilePics(diameter: 140, path: _userProfile['profile']),
            _buildFullName(),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: ListTile(
                leading: Icon(Icons.cake),
                title: Text(_userProfile['birthdate'].toString()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text(_userProfile['email']),
            ),
            _isOwner
                ? RaisedButton(
                    child: Text('Edit Profile'),
                    onPressed: () {},
                  )
                : RaisedButton(
                    child: Text('Add Friend!'),
                    onPressed: () {},
                  ),
            _isOwner
                ? RaisedButton(
                    child: Text('Friends List'),
                    onPressed: () {},
                  )
                : null
          ];
    if (_list != null)
      _list.addAll(_posts.keys.map((k) {
        return GestureDetector(
          // link ไปยังโพสต์โดยการแก้ on tap function
          onTap: () => print('navagate!'),
          child: ProfilePosts(
            profile: ProfilePics(diameter: 50, path: _userProfile['profile']),
            dname: _userProfile['dname'],
            detail: _posts[k]['detail'],
            date: _posts[k]['dateCreated'],
          ),
        );
      }));

    Widget _profilePage = !isFinish
        ? Center(child: CircularProgressIndicator())
        : ListView(
            children: _list,
          );

    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: _profilePage);
  }
}

import 'package:fitsbook/Profile/EditProfile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import './Profile/Post.dart';
import './Profile/ProfilePic.dart';
import './FriendRequest/Friendlist.dart';

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
  bool _isFriend = false;
  int _isRequest = 0;
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
        // เช็คว่าเป็นเพื่อนกันอยู่ไหม
        // เช็คว่ามีการรีเควสเป็นเฟรนด์ไปแล้วหรือไม่
        List<dynamic> friends = doc.data['friends'];
        readFile('userId').then((String userId) {
          if (friends != null && friends.contains(userId))
            setState(() {
              _isFriend = true;
            });
          else {
            // check ว่ามีการส่งรีเควสไปไหม ถ้าเจ้าของเครื่องส่งไป -1 ถ้าเขาส่งมา 1 ถ้าเป็น 0 คือไม่มีอะไรเกิดขึ้น
            CollectionReference ref = Firestore.instance.collection('users');
            ref
                .document(userId)
                .collection('requests')
                .document(_uid)
                .get()
                .then((DocumentSnapshot d) {
              if (d.exists)
                setState(() {
                  _isRequest = 1;
                });
            });
            ref
                .document(_uid)
                .collection('requests')
                .document(userId)
                .get()
                .then((DocumentSnapshot d) {
              if (d.exists)
                setState(() {
                  _isRequest = -1;
                });
            });
          }
        });

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
    // ตรงนี้เอาไว้สร้างปุ่มว่าเป็นหน้าของเจ้าของเองแสดงปุ่มแบบนึง
    List<Widget> allButton;
    if (_isOwner) {
      allButton = [
        ButtonTheme(
          buttonColor: Colors.green,
          child: RaisedButton(
            child: 
            Text('Edit Profile'
            ,style: TextStyle(color: Colors.white),),
          // todo: nav ไปหน้า edit profile ตรงงน้
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatedForm(_userProfile, _uid)));
          },
          ),
        ),
        ButtonTheme(
          buttonColor: Colors.green,
          child: RaisedButton(
            child: 
            Text('Friends List'
            ,style: TextStyle(color: Colors.white),),
          // todo: nav ไปหน้า edit profile ตรงงน้
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FriendList()),
            );
          },
          ),
        ),
      ];
    } else if (_isFriend) {
      allButton = [
        RaisedButton(
          child: Text('Chat'),
          onPressed: () {
            print('chat');
          },
        ),
      ];
    } else if (_isRequest == 1) {
      allButton = [
        Center(
          child: Text(
            'You have a friend request from this user',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        RaisedButton(
          child: Text('Accept'),
          onPressed: () async {
            FirebaseUser user = await FirebaseAuth.instance.currentUser();
            await Firestore
              .instance
              .collection('users')
              .document(user.uid)
              .collection('requests')
              .document(_uid)
              .setData({
                'status': 'accepted',
              }, merge: true);
              setState(() {
               _isFriend = true; 
              });
          },
        ),
      ];
    } else if (_isRequest == -1) {
      allButton = [
        Center(
          child: Text(
            'You have sent this user a friend request',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        )
      ];
    } else {
      allButton = [
        RaisedButton(
          child: Text('Add friend!'),
          onPressed: () async {
            FirebaseUser user = await FirebaseAuth.instance.currentUser();
            await Firestore
              .instance
              .collection('users')
              .document(_uid)
              .collection('requests')
              .document(user.uid)
              .setData({
                'status': 'waiting',
                'dateCreated': DateTime.now().millisecondsSinceEpoch
              }, merge: true);
              setState(() {
               _isRequest = -1;
              });
          },
        ),
      ];
    }

    List<Widget> _list;
    if (_userProfile != null) {
      _list = [
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
      ];
      _list.addAll(allButton == null ? [] : allButton);
      _list = _list.where((Widget w) => w != null).toList();
    }

    if (_list != null)
      _list.addAll(_posts.keys.map((k) {
        return GestureDetector(
          // link ไปยังโพสต์โดยการแก้ on tap function
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Profile(_uid)),
              ),
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
          title: Center(
            child: Image.asset('resources/logo.PNG', fit: BoxFit.cover, width: 25,)
          )
        ),
        body: _profilePage);
  }
}

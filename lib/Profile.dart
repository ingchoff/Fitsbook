import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitsbook/Chat/homepage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formkey = GlobalKey<FormState>();
  
  String dname;
  String fname;
  String gender;
  String lname;
  File testImage;
  String uid;

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

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      testImage = tempImage;
    });
  }

  Future<bool> updateDialog(BuildContext context, selectedDoc) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return 
          AlertDialog(
            title: Text('Update Data', style: TextStyle(fontSize: 15.0)),
            content: Container(
              height: 500.0,
              width: 150.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter new username'),
                    onChanged: (value) {
                      this.dname = value;
                    },
                  ),
                  SizedBox(height: 5.0),
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter firstname'),
                    onChanged: (value) {
                      this.fname = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter gender'),
                    onChanged: (value) {
                      this.gender = value;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Enter lastname'),
                    onChanged: (value) {
                      this.lname = value;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child:  testImage == null ? Text('Select an Image') : enableUpload(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FloatingActionButton(
                onPressed: getImage,
                child: new Icon(Icons.add),
              ),
              FlatButton(
                child: Text('Update'),
                textColor: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                  updateData(selectedDoc, {
                    'dname': this.dname,
                    'fname': this.fname,
                    'gender': this.gender,
                    'lname': this.lname
                  }).then((result) {
                  }).catchError((e) {
                    print(e);
                  });
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('resources/logo.PNG', fit: BoxFit.cover, width: 25,)
        )
      ),
      body:  StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData);
            return FlatButton(
              child: Text('Update Profile'),
              textColor: Colors.blue,
              color: Colors.white,
              onPressed: () {
                updateDialog(context,  snapshot.data.documents[0].documentID);
              },
            );
          }
        ),
      // Center(
      //   child: Text(_uid),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        },
        child: Icon(Icons.chat),
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(testImage, height: 200, width: 200),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              final StorageReference firebaseStorageRef =
                FirebaseStorage.instance.ref().child('photo.jpg');
              final StorageUploadTask task =
                firebaseStorageRef.putFile(testImage);
            },
          )
        ],
      ),
    );
  }
  getData() async {
    return await Firestore.instance.collection('users').getDocuments();
  }
  updateData(selectedDoc, newValues) {
    Firestore.instance
        .collection('users')
        .document(selectedDoc)
        .updateData(newValues)
        .catchError((e) {
      print(e);
    });
  }
}



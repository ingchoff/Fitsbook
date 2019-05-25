import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore store = Firestore.instance;

class UpdatedForm extends StatefulWidget {
  @override
  UpdatedFormState createState() => new UpdatedFormState();
}

class UpdatedFormState extends State<UpdatedForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String dname;
  String fname;
  String gender;
  String lname;
  File image;
  String uid;

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = tempImage;
    });
  }

  Future<bool> updateDialog(BuildContext context, selectedDoc) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update Data', style: TextStyle(fontSize: 15.0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            content: Container(
              height: 350.0,
              width: 150.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    child:  image == null ? Text('Select an Image') : enableUpload(),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FloatingActionButton(
                onPressed: getImage,
                child: new Icon(Icons.add_a_photo),
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
                  // Firestore.instance.collection('users').add({
                  //   'photoUrl' 
                  // });
                },
              )
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Edit profile'),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData);
            return Center(
              child: FlatButton(
                child: Text('Update Profile'),
                textColor: Colors.white,
                color: Colors.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                onPressed: () {
                  updateDialog(context,  snapshot.data.documents[0].documentID);
                },
              )
            );
          }
        )
    );
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(image, height: 100, width: 100),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              final StorageReference firebaseStorageRef =
                FirebaseStorage.instance.ref().child('profile/photo.jpg');
              final StorageUploadTask task =
                firebaseStorageRef.putFile(image);
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

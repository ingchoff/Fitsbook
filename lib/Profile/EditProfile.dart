import 'package:fitsbook/Profile/ProfilePic.dart';
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
  Map<String, dynamic> userProfile;
  String uid;
  UpdatedForm(this.userProfile, this.uid);
  @override
  UpdatedFormState createState() => new UpdatedFormState();
}

class UpdatedFormState extends State<UpdatedForm> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formkey = GlobalKey<FormState>();
  TextEditingController dname;
  TextEditingController fname;
  TextEditingController gender;
  TextEditingController lname;
  TextEditingController birthday;
  int route = 0;
  bool _isLoading = false;
  bool _notHaveDname = false;
  Map<String, dynamic> _userProfile;
  String _uid;
  String _image;
  // String dname;
  // String fname;
  // String gender;
  // String lname;
  // File image;
  // String uid;

  @override
  void initState() {
    super.initState();
    // setUser();
    _userProfile = widget.userProfile;
    _uid = widget.uid;
    _image = _userProfile['profile'];
    dname = TextEditingController(text: _userProfile['dname']);
    fname = TextEditingController(text: _userProfile['fname']);
    lname = TextEditingController(text: _userProfile['lname']);
    gender = TextEditingController(text: _userProfile['gender']);
    birthday = TextEditingController(text: _userProfile['birthdate'].toString());
    if (gender.text == 'male') {
      setState(() {
        route = 0;
      });
    } else {
      setState(() {
        route = 1;
      });
    }
  }

  Widget setUpButtonChild() {
    if (_isLoading) {
      return CircularProgressIndicator();
    }else {
      return new Text('Update Profile', style: TextStyle(color: Colors.white),);
    }
  }

  void setUser() {
    Firestore.instance.collection('users').document(_uid).get().then((doc) {
      setState(() {
        _userProfile = doc.data;
      });
    });
  }

  Future<void> changeProfile() async {
    final scaffoldState =_scaffoldKey.currentState;
    final formState = _formkey.currentState;
    if(formState.validate()) {
      formState.save();
      setState(() {
       _isLoading = true;
      });
      String txt;
      QuerySnapshot users = await store.collection('users').getDocuments();
      for(var i=0;i<users.documents.length;i++) {
        txt = users.documents[i].data['dname'];
        if(dname.text == txt && _userProfile['dname'] == dname.text) {
          _notHaveDname = true;
          break;
        } else if (dname.text == txt && _userProfile['dname'] != dname.text) {
          _notHaveDname = false;
        }
        else {
          _notHaveDname = true;
        }
      }
      if (_notHaveDname) {
        store.collection('users').document(_uid).setData({
          'dname': dname.text,
          'fname':fname.text,
          'lname':lname.text,
          'birthdate': int.parse(birthday.text),
          'gender': gender.text,
          'profile': _image
        },merge: true);
        _userProfile['dname'] = dname.text;
        _userProfile['fname'] = fname.text;
        _userProfile['lname'] = lname.text;
        _userProfile['birthdate'] = birthday.text;
        _userProfile['gender'] = gender.text;
        _userProfile['profile'] = _image;
        setState(() {
          _isLoading = false; 
        });
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          });
        scaffoldState.showSnackBar(new SnackBar(
          content: new Text('Display Name นี้ถูกใช้แล้ว'),
        ));
      }
    }
  }

  Future getImage(_uid) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profile/${_uid}/profile');
    final StorageUploadTask task = firebaseStorageRef.putFile(image);
    String tmpUrl = firebaseStorageRef.getDownloadURL().toString();
    var downUrl = await (await task.onComplete).ref.getDownloadURL();
    var url = downUrl.toString();
    print(url);
    setState(() {
      _image = url;
    });

    // setState(() {
    //   _image = image;
    // });
  }

  // Future<bool> updateDialog(BuildContext context, selectedDoc) async {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Update Data', style: TextStyle(fontSize: 15.0)),
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
  //           content: Container(
  //             height: 350.0,
  //             width: 150.0,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: <Widget>[
  //                 TextField(
  //                   decoration: InputDecoration(hintText: 'Enter new displayname'),
  //                   controller: dname,
  //                 ),
  //                 SizedBox(height: 5.0),
  //                 TextField(
  //                   decoration: InputDecoration(hintText: 'Enter firstname'),
  //                   controller: fname,
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(hintText: 'Enter gender'),
  //                   controller: gender,
  //                 ),
  //                 TextField(
  //                   decoration: InputDecoration(hintText: 'Enter lastname'),
  //                   controller: lname,
  //                 ),
  //                 // Padding(
  //                 //   padding: const EdgeInsets.only(top: 10),
  //                 //   child:  image == null ? Text('Select an Image') : enableUpload(),
  //                 // ),
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[
  //             FloatingActionButton(
  //               onPressed: getImage,
  //               child: new Icon(Icons.add_a_photo),
  //             ),
  //             FlatButton(
  //               child: Text('Update'),
  //               textColor: Colors.blue,
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 updateData(selectedDoc, {
  //                   'dname': this.dname,
  //                   'fname': this.fname,
  //                   'gender': this.gender,
  //                   'lname': this.lname
  //                 }).then((result) {
  //                 }).catchError((e) {
  //                   print(e);
  //                 });
  //                 // Firestore.instance.collection('users').add({
  //                 //   'photoUrl' 
  //                 // });
  //               },
  //             )
  //           ],
  //         );
  //       });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Edit profile'),
          centerTitle: true,
        ),
        body: Form(
          key: _formkey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              Padding(
              padding: EdgeInsets.only(top: 20),
              child: TextFormField(
                validator: (String value) {
                  if(value.isEmpty) {
                    return 'โปรดระบุชื่อ';
                  }
                },
                controller: fname,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person)
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: TextFormField(
                validator: (String value) {
                  if(value.isEmpty) {
                    return 'โปรดระบุนามสกุล';
                  }
                },
                controller: lname,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person)
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: TextFormField(
                validator: (String value) {
                  if(value.isEmpty) {
                    return 'โปรดระบุ display name';
                  }
                },
                controller: dname,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person)
                ),
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Radio(
                  value: 0,
                  groupValue: route,
                  onChanged: (value) {
                    setState(() {
                      route = value;
                      if(route == 0) {
                        gender.text = 'male';
                      }
                      print(gender.text);
                    });
                  },
                ),
                new Text('ชาย'),
                new Radio(
                  value: 1,
                  groupValue: route,
                  onChanged: (value) {
                    setState(() {
                      route = value; 
                      if(route == 1) {
                        gender.text = 'female';
                      }
                      print(gender.text);
                    });
                  },
                ),
                new Text('หญิง')
              ],
            ),
            TextFormField(
              validator: (value) {
                if (value.length != 8) {
                  return 'รุปแบบวัน เดือน ปี ไม่ถูกต้อง';
                }
              },
              controller: birthday,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                hintText: 'yyyymmdd',
                labelText: 'birthday',
                prefixIcon: Icon(Icons.date_range)
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Center(
                child: _image == null ? 
                RaisedButton(
                  onPressed: () {
                    getImage(_uid);
                  },
                  child: Text('Add Profile Image'),
                ):
                Column(
                  children: <Widget>[
                    Text('Tap image To Change an image', style: TextStyle(fontSize: 10)),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () {
                          getImage(_uid);
                        },
                        child: CircleAvatar(
                          radius: 100.0,
                          backgroundImage:
                              NetworkImage(_image),
                          backgroundColor: Colors.transparent,
                        )
                      )
                    )
                  ],
                )
              )
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: SizedBox(
              height: 50,
              child: RaisedButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: setUpButtonChild(),
                onPressed: changeProfile,
                  )
                ),
            ),
            ],
          ),
        ),
        // body: StreamBuilder(
        //   stream: Firestore.instance.collection('users').snapshots(),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData);
        //     return Center(
        //       child: FlatButton(
        //         child: Text('Update Profile'),
        //         textColor: Colors.white,
        //         color: Colors.lightBlue,
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        //         onPressed: () {
        //           updateDialog(context,  snapshot.data.documents[0].documentID);
        //         },
        //       )
        //     );
        //   }
        // )
        // floatingActionButton: FloatingActionButton(
        //   onPressed: getImage,
        //   tooltip: 'Pick Image',
        //   child: Icon(Icons.add_a_photo),
        // ),
    );
  }

  // Widget enableUpload() {
  //   return Container(
  //     child: Column(
  //       children: <Widget>[
  //         Image.file(image, height: 100, width: 100),
  //         RaisedButton(
  //           elevation: 7.0,
  //           child: Text('Upload'),
  //           textColor: Colors.white,
  //           color: Colors.blue,
  //           onPressed: () {
  //             final StorageReference firebaseStorageRef =
  //               FirebaseStorage.instance.ref().child('profile/photo.jpg');
  //             final StorageUploadTask task =
  //               firebaseStorageRef.putFile(image);
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }
  // getData() async {
  //   return await Firestore.instance.collection('users').getDocuments();
  // }
  // updateData(selectedDoc, newValues) {
  //   Firestore.instance
  //       .collection('users')
  //       .document(selectedDoc)
  //       .updateData(newValues)
  //       .catchError((e) {
  //     print(e);
  //   });
  // }
}

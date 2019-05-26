import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  final formatter1 = new DateFormat('yyyyMMdd');
  DateTime birthdate;

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
    birthdate = DateTime(int.parse(birthday.text.substring(0,4)),
              int.parse(birthday.text.substring(4,6)), int.parse(birthday.text.substring(6,8)));
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

  Widget setUpImage() {
    if (_isLoading) {
      return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),);
    } else {
      return GestureDetector(
        onTap: () {
          getImage(_uid);
        },
        child: CircleAvatar(
          radius: 100.0,
          backgroundImage:
          NetworkImage(_image),
          backgroundColor: Colors.transparent,
        )
      );
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
      String txt;
      QuerySnapshot users = await store.collection('users').getDocuments();
      for(var i=0;i<users.documents.length;i++) {
        txt = users.documents[i].data['dname'];
        if(dname.text == txt && dname.text != _userProfile['dname']) {
          _notHaveDname = false;
          break;
        } else if (dname.text != txt) {
          _notHaveDname = true;
        } else if (dname.text == txt && dname.text == _userProfile['dname']) {
          _notHaveDname = true;
        }
      }
      if (_notHaveDname) {
        store.collection('users').document(_uid).setData({
          'dname': dname.text,
          'fname':fname.text,
          'lname':lname.text,
          'birthdate': int.parse(formatter1.format(birthdate)),
          'gender': gender.text,
          'profile': _image
        },merge: true);
        _userProfile['dname'] = dname.text;
        _userProfile['fname'] = fname.text;
        _userProfile['lname'] = lname.text;
        _userProfile['birthdate'] = formatter1.format(birthdate);
        _userProfile['gender'] = gender.text;
        _userProfile['profile'] = _image;
        Navigator.of(context).pop();
      } else {
        scaffoldState.showSnackBar(new SnackBar(
          content: new Text('Display Name นี้ถูกใช้แล้ว'),
        ));
      }
    }
  }

  Future getImage(_uid) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image.length == 0) {
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profile/${_uid}/profile');
    final StorageUploadTask task = firebaseStorageRef.putFile(image);
    var downUrl = (await task.onComplete).ref.getDownloadURL();
    downUrl.then((value) {
      setState(() {
        _image = value;
        _isLoading = false;
      });
    });
  }
  
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
            DateTimePickerFormField(
              initialValue: DateTime(int.parse(birthday.text.substring(0,4)),
              int.parse(birthday.text.substring(4,6)), int.parse(birthday.text.substring(6,8))),
              inputType: InputType.date,
              format: DateFormat("yyyy-MM-dd"),
              initialDate: DateTime(2000, 1, 1),
              editable: false,
              decoration: InputDecoration(
                labelText: birthday.text,
                hasFloatingPlaceholder: false
              ),
              onChanged: (dt) {
                setState(() => birthdate = dt);
                print(formatter1.format(birthdate));
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Center(
                child: _image == null || _image == '' ? 
                RaisedButton(
                  onPressed: () {
                    getImage(_uid);
                  },
                  child: Text('Add Profile Image'),
                ):
                Column(
                  children: <Widget>[
                    Text('Tap image To Change an image', style: TextStyle(fontSize: 13)),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: setUpImage()
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
                child: Text('Update Profile', style: TextStyle(color: Colors.white)),
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

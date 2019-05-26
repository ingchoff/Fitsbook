import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore store = Firestore.instance;

class Register extends StatefulWidget {
  @override
  RegisterState createState() {
    return RegisterState();
  }
}

class RegisterState extends State<Register> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int route = 0;
  final _formkey = GlobalKey<FormState>();
  final fname = TextEditingController();
  final lname = TextEditingController();
  final dname =TextEditingController();
  final email = TextEditingController();
  String sex = 'male';
  final password = TextEditingController();
  final conPassword = TextEditingController();
  bool _isLoading = false;
  bool _notHaveDname = false;
  final formatter1 = new DateFormat('yyyy-MM-dd kk:mm');
  final formatter2 = new DateFormat('yyyyMMdd');
  String txt;
  DateTime birthdate;

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    email.dispose();
    password.dispose();
    conPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Register'),
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
                       sex = 'male';
                     }
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
                       sex = 'female';
                     }
                    });
                  },
                ),
                new Text('หญิง')
              ],
            ),
            DateTimePickerFormField(
              inputType: InputType.date,
              format: DateFormat("yyyy-MM-dd"),
              initialDate: DateTime(2000, 1, 1),
              editable: false,
              decoration: InputDecoration(
                labelText: 'Birth Date',
                hasFloatingPlaceholder: false
              ),
              onChanged: (dt) {
                setState(() => birthdate = dt);
                print(formatter2.format(birthdate));
              },
            ),
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: TextFormField(
                validator: (String value) {
                  if(value.isEmpty) {
                    return 'โปรดระบุ Display Name';
                  }
                },
                controller: dname,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person_outline)
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: TextFormField(
                validator: (String value) {
                  if(value.isEmpty) {
                    return 'โปรดระบุ email';
                  }
                },
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email)
                ),
              ),
            ),
            TextFormField(
              validator: (String value) {
                if (value.isEmpty) {
                  return 'โปรดระบุ Password';
                }else if(value.length <= 6) {
                  return 'Password ต้องมากกว่า 6 ตัวอักษร';
                }
              },
              controller: password,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.https)
                ),
              ),
              TextFormField(
              validator: (String value) {
                if (value.isEmpty) {
                  return 'โปรดระบุ Password';
                }else if(value.length <= 6) {
                  return 'Password ต้องมากกว่า 6 ตัวอักษร';
                }
              },
              controller: conPassword,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.https)
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
              height: 50,
              child: RaisedButton(
                color: Colors.lightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: setUpButtonChild(),
                onPressed: signUp,
                  )
                ),
            ),
          ],
        ),
      )
    );
  }

  Widget setUpButtonChild() {
    if (_isLoading) {
      return CircularProgressIndicator();
    }else {
      return new Text('Register'
      ,style: TextStyle(
        color: Colors.white
      ),);
    }
  }

  Future<void> checkDname(dname) async {
    String txt;
    QuerySnapshot users = await store.collection('users').getDocuments();
    for(var i=0;i<users.documents.length;i++) {
      txt = users.documents[i].data['dname'];
      if(dname == txt) {
        _notHaveDname = false;
        break;
      } else {
        _notHaveDname = true;
      }
    }
    print(_notHaveDname);
  }

  Future<void> signUp() async {
    final scaffoldState =_scaffoldKey.currentState;
    final formState = _formkey.currentState;
    if(formState.validate() && password.text == conPassword.text){
      formState.save();
      setState(() {
       _isLoading = true;
      });
      String txt;
      QuerySnapshot users = await store.collection('users').getDocuments();
      for(var i=0;i<users.documents.length;i++) {
        txt = users.documents[i].data['dname'];
        if(dname.text == txt) {
          _notHaveDname = false;
          break;
        } else {
          _notHaveDname = true;
        }
      }
      if (_notHaveDname) {
        try{
            FirebaseUser user = await _auth.createUserWithEmailAndPassword(email: email.text, password: password.text);
            user.sendEmailVerification();
            print(user.uid);
            store.collection('users').document(user.uid).setData({
              'fname':fname.text,
              'lname':lname.text,
              'gender':sex,
              'email':email.text,
              'dname':dname.text,
              'birthdate': int.parse(formatter2.format(birthdate)),
              'joinDate':formatter1.format(DateTime.now()),
              'profile':""});
            setState(() {
            _isLoading = false; 
            });
            scaffoldState.showSnackBar(new SnackBar(
              content: new Text('สมัครเรียบร้อย'),
            ));
            Navigator.of(context).pop();
        }catch(e){
          setState(() {
          _isLoading = false; 
          });
          if(e.message == 'The email address is already in use by another account.') {
            scaffoldState.showSnackBar(new SnackBar(
              content: new Text('Email นี้ถูกใช้แล้ว'),
            ));
          }
        }
      } else {
          setState(() {
          _isLoading = false;
          });
          scaffoldState.showSnackBar(new SnackBar(
            content: new Text('Display Name นี้ถูกใช้แล้ว'),
          ));
      }
    }else if (formState.validate() && password.text != conPassword.text){
      scaffoldState.showSnackBar(new SnackBar(
        content: new Text('กรุณากรอก Confirm Password ให้ถูกต้อง'),
      ));
    }
  }
}
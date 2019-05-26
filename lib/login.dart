import 'dart:async';
import 'dart:io';
import './MainPage.dart';
import './register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
	@override
	LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final Firestore store = Firestore.instance;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	final _formKey = GlobalKey<FormState>();
  final textValue1 = TextEditingController();
  final textValue2 = TextEditingController();
  String token;

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((user){
      if (user.uid != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(user: user)));
      } else {
        build(context);
      }
    });
    _firebaseMessaging.getToken().then((value){
      token = value;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    textValue1.clear();
    textValue2.clear();
    super.dispose();
  }

  Widget setUpButtonChild() {
    if (_isLoading) {
      return CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),);
    }else {
      return new Text('LOGIN', style: TextStyle(color: Colors.white),);
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          title: new Text("Please, Verify Email"),
          content: new Text("โปรดยืนยัน Email ก่อนเข้าสู่ระบบ"),
          actions: <Widget>[
            new FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
              ),
              color: Colors.lightBlueAccent,
              child: new Text("OK",style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    final scaffoldState =_scaffoldKey.currentState;
    if (formState.validate()) {
      formState.save();
      setState(() {
       _isLoading = true; 
      });
      try{
        // Sign in
        FirebaseUser user = await _auth.signInWithEmailAndPassword(email: textValue1.text, password: textValue2.text);
        //check comfirmed email
        // if (user.isEmailVerified) {
          setState(() {
            _isLoading = false;
          });
          //get token
          _firebaseMessaging.getToken().then((String value){
            // token = value;
            setState(() {
              token = value;
            });
          });
          store.collection('users').document(user.uid).setData({ //add noti_token เก็บบน cloud firestore
            'noti_token':token
          },merge: true);
          await writeFile(user,token); //save ค่า uid, email, token ลง data.txt
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(user: user,)));//ถ้า Login สำเร็จจะไปที่หน้าหลักที่มีการดึงข้อมูลมาจาก local storage
        // } else {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   _showDialog();
        // }
      }catch(e){
        print(e.message);
        setState(() {
         _isLoading = false;
        });
        if(e.message == 'The email address is badly formatted.') {
          scaffoldState.showSnackBar(new SnackBar(
            content: new Text('Email ไม่ถูกต้อง'),
          ));
        } else if(e.message == 'The password is invalid or the user does not have a password.') {
          scaffoldState.showSnackBar(new SnackBar(
            content: new Text('Password ไม่ถูกต้อง'),
          ));
        } else if(e.message == 'There is no user record corresponding to this identifier. The user may have been deleted.') {
          scaffoldState.showSnackBar(new SnackBar(
            content: new Text('ไม่พบ Email นี้ในระบบ'),
          ));
        }
      }
    }
  }

  //หา local path ของแอพ
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  //สร้างไฟล์ data.txt
  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/data.txt');
  }
  //เก็บค่า uid และ email ไว้ในไฟล์ data.txt
  Future<File> writeFile(user,token) async {
    final file = await _localFile;
    var users = await store.collection('users').document(user.uid).get();
    String fname = users.data['fname'];
    String lname = users.data['lname'];
    String dname = users.data['dname'];
    String profile = users.data['profile'];
    String gender = users.data['gender'];
    String birthdate = users.data['birthdate'].toString();
    print(fname);
    String data = '{"userId":'+'"'+user.uid+'"'+',"email":"'+user.email+'"'+',"token":"$token"'+
    ',"dname":"'+dname+'"'+',"fname":"'+fname+'"'+
    ',"lname":"'+lname+'"'+',"profile":"'+profile+'"'+
    ',"gender":"'+gender+'"'+',"birthdate":"'+birthdate+'"'+'}';
    print(data);
    return file.writeAsString(data); // Write the file
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100),
              child: Image.asset('resources/logo.PNG',height: 100,),
            ),  
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Please, enter Email';
                  }
                },
                controller: textValue1,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 30),
              child: TextFormField(
                keyboardType: TextInputType.text,
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Please, enter password';
                  }
                },
                controller: textValue2,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.https),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                ),
                obscureText: true,
                ),
            ),   
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 50,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: signIn,
                  child: setUpButtonChild(),
                  color: Colors.green,
                ),
              )
            ),
            FlatButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
              },
              child: Text('Register New Account',style: TextStyle(color: Colors.green, fontSize: 16),textAlign: TextAlign.right,),
            ),
          ]
        )
      )
    );
  }
}
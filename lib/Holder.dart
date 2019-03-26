import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Holder extends StatelessWidget {
  final String title;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Holder(this.title);

  void _logout(context) async {
    await auth.signOut();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(children: <Widget>[
        Center(child: Text(title)),
        RaisedButton(child: Text('Log Out'), onPressed: () => _logout(context),)
        ],
      ),
    );
  }
}

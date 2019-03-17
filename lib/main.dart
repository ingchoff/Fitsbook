import 'package:fitsbook/login.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Fitsbook';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        body: Login(),
      ),
    );
  }
}

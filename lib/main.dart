import 'package:fitsbook/MainPage.dart';
import 'package:flutter/material.dart';
import './login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Fitsbook';

    return MaterialApp(
      title: appTitle,
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => Login(),
        '/main' : (BuildContext context) => MainPage()
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

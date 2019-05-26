import 'package:flutter/material.dart';
import './login.dart';
import 'NewFeed/map_screen.dart';

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
        '/map': (BuildContext context) => MapScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}

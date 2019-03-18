import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class NewFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewFeedState();
  }
}

class _NewFeedState extends State<NewFeed> {

  String txt;

  @override
  void initState() {
    super.initState();
    //อ่านค่า email ของ uid ที่ signin เข้ามา ในไฟล์ data.txt
    // readFile('ชื่อ key ที่อยากดึง value มาใข้')
    readFile('email').then((String value) {
      txt = value;
    });
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
      setState(() {
       txt = contents[key];
      });
      print(contents); // พิม data ในรูปแบบ json บน console
      print(contents[key]); // พิม data ตาม key ที่เราใส่เข้าไปในรูปแบบ string บน console
      return contents[key]; //ส่งค่ากลับ ตาม key ที่เราใส่เข้าไปในรูปแบบ string
    } catch (e) {
      print(e);
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MainPage')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Column(
            children: <Widget>[
              Text('Account Info: $txt'),
              RaisedButton(
                onPressed: () => readFile('userId'),
                child: Text('data'),
              ),
            ],
          ),
        )
        
      ),
    );
  }
}
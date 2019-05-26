import 'package:fitsbook/FriendRequest/Request.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import './Friend.dart';

DateTime _now = DateTime.now();

class RequestList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RequestListState();
  }
}

class _RequestListState extends State<RequestList> {
  Map<String, dynamic> friendsLists = {};

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<String> readFile(String key) async {
    try {
      final file = await _localFile;
      // Read the file
      Map contents = json.decode(await file.readAsString());
      return contents[key];
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<Map<String, dynamic>> getRequests() async {
    Map<String, dynamic> _friendsLists = {};

    String userId = await readFile('userId');
    DocumentSnapshot docs =
        await Firestore.instance.collection('users').document(userId).get();
    print(docs.data['friends']);
    for (String f in docs.data['friends']) {
      _friendsLists[f] = {};
      DocumentSnapshot profileDocs =
          await Firestore.instance.collection('users').document(f).get();
      _friendsLists[f]['dname'] = profileDocs.data['dname'];
      _friendsLists[f]['path'] = profileDocs.data['profile'];
      DocumentSnapshot requests = await Firestore.instance.collection('users').document(f).collection('requests').document(userId).get();
      print(requests.data['status']);
    }

    print(_friendsLists);
    print(_friendsLists.runtimeType);
    return _friendsLists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(8, 5, 8, 5),
        child: FutureBuilder<Map<String, dynamic>>(
          future: getRequests(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            var allReq = snapshot.data;
            if (allReq == null)
              return (_now.compareTo(DateTime.now()) > 3)
              ? Center(
                child: Text('You have no request friend now!'),
              )
              : Center(
                child: CircularProgressIndicator(),
              );
            return allReq.keys.length == 0
                ? Center(
                    child: Text('You have no request friend now!'),
                  )
                : ListView.builder(
                    itemCount: allReq.keys.length,
                    itemBuilder: (context, index) {
                      String key = allReq.keys.toList()[index];
                      return Request(
                        dname: allReq[key]['dname'],
                        profilePath: allReq[key]['path']
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}

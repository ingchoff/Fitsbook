import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import './Friend.dart';
import '../Profile.dart';

DateTime _now = DateTime.now();

class FriendList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FriendListState();
  }
}

class _FriendListState extends State<FriendList> {
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
    }

    print(_friendsLists);
    print(_friendsLists.runtimeType);
    return _friendsLists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
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
                      child: Text('You have no friend now!'),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    );
            return allReq.keys.length == 0
                ? Center(
                    child: Text('You have no friend now!'),
                  )
                : ListView.builder(
                    itemCount: allReq.keys.length,
                    itemBuilder: (context, index) {
                      String key = allReq.keys.toList()[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Profile(key)),
                          );
                        },
                        child: Friend(
                          dname: allReq[key]['dname'],
                          profilePath: allReq[key]['path'],
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}

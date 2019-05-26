import 'package:flutter/material.dart';
import './FriendRequest/Request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FriendRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FriendRequest();
  }
}

class _FriendRequest extends State<FriendRequest> {
  Map<String, dynamic> requests = {};

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
  
  void onAccept(String key) async {
    // ทำการยอมรับเพื่อน
    String userId = await readFile('userId');
    requests.remove(key);
    Firestore
      .instance
      .collection('users')
      .document(userId)
      .collection('requests')
      .document(key)
      .setData({
        'status': 'accepted'
      }, merge: true);
  }

  Future<Map<String, dynamic>> getRequests() async {
    // ดึงข้อมูลคำขอเป็นเพื่อน ที่มีสถานะเป็น waiting
    Map<String, dynamic> _requests = {};

    String userId = await readFile('userId');
    QuerySnapshot docs = await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('requests')
        .where("status", isEqualTo: "waiting")
        .orderBy('dateCreated', descending: true)
        .getDocuments();

    for (DocumentSnapshot f in docs.documents) {
      _requests[f.documentID] = f.data;
      DocumentSnapshot profileDocs = await Firestore.instance
          .collection('users')
          .document(f.documentID)
          .get();
      _requests[f.documentID]['dname'] = profileDocs.data['dname'];
      _requests[f.documentID]['path'] = profileDocs.data['profile'];
    }
    setState(() {
     requests = _requests; 
    });
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends Requests'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(8, 5, 8, 5),
        child: FutureBuilder<Map<String, dynamic>>(
          future: getRequests(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            var allReq = snapshot.data;
            if (allReq == null)
              return Center(
                child: CircularProgressIndicator(),
              );
            return allReq.keys.length == 0
                ? Center(
                    child: Text('No Friend Request!'),
                  )
                : ListView.builder(
                    itemCount: allReq.keys.length,
                    itemBuilder: (context, index) {
                      String key = allReq.keys.toList()[index];
                      return Request(
                        dname: allReq[key]['dname'],
                        profilePath: allReq[key]['path'],
                        onAccepted: () => onAccept(key),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
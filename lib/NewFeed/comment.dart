import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitsbook/NewFeed/new_feed.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment extends StatefulWidget {
  final String title;
  final int no;
  final String userPic;
  final String userId;
  Comment({this.title, this.no, this.userPic, this.userId});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CommentState();
  }
}

class CommentState extends State<Comment> {
  String urlPicPost;
  final TextEditingController comment_Word = TextEditingController();
  getUrlForPost(String path) async {
    StorageReference ref = 
        FirebaseStorage.instance.ref().child(path);
    String url = (await ref.getDownloadURL()).toString();
    // print(url);
    if (url == null) url = 'https://upload.wikimedia.org/wikipedia/commons/d/d2/Question_mark.svg';
    setState(() {
      urlPicPost = url;
    });
  }

  String urlUserPost;
  getUrlForPostUser(String userId) async {
    StorageReference ref = 
        FirebaseStorage.instance.ref().child("profile/$userId/profile.jpg");
    String url = (await ref.getDownloadURL()).toString();
    // print(url);
    if (url == null) url = 'https://upload.wikimedia.org/wikipedia/commons/d/d2/Question_mark.svg';
    setState(() {
      urlUserPost = url;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
      ),
      body: ListView(
        children: <Widget>[
          Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('posts').orderBy("dateCreated").snapshots(),
              builder: (context, snapshot) {
                if(snapshot.data == null) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                getUrlForPostUser(snapshot.data.documents[widget.no]['user']);
                getUrlForPost(snapshot.data.documents[widget.no]['photo'][0]);
                String place = '';
                double userSize = 18;
                double placeSize = 10;
                double frameSize = 480;
                if (snapshot.data.documents[widget.no]['place'] != null || snapshot.data.documents[widget.no]['place'] != '') {
                  userSize = 12;
                  place = 'อยู่ที่ ' + snapshot.data.documents[widget.no]['place'];
                  if (place.length > 40) { place = place.substring(0, 40) + '...'; }
                }
                if (place == "") {
                  place = "";
                  placeSize = 0;
                }
                return new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children : <Widget>[
                    Text('             '),
                    Container(
                      // margin: EdgeInsets.only(top: 20.0), 
                      // padding: EdgeInsets.only(top: 20.0), 
                      
                      
                      // decoration: BoxDecoration(
                      //   color: Colors.greenAccent,
                      //   border: Border.all(
                      //     color: Colors.black,
                      //     width: 2.0,
                      //   ),
                      //   borderRadius: BorderRadius.circular(12)
                      // ),
                      child: Column(     
                        crossAxisAlignment: CrossAxisAlignment.start,                                     
                        children: <Widget>[
                          Row(children: <Widget>[

                          Text("        "),
                          urlUserPost == null 
                          ? new Image.asset('resources/logo.PNG', fit: BoxFit.cover, width: 25,)
                          : new Image.network(
                            urlUserPost,
                            width: 40,
                            height: 40,
                          ),
                          Text("   "),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StreamBuilder<QuerySnapshot>(
                          stream: Firestore.instance.collection('users').snapshots(),
                          builder: (context, snapshot2) {
                            String userpost = "";
                            for (var item in snapshot2.data.documents) {
                              if (item.documentID == snapshot.data.documents[widget.no]['user']) {
                                userpost = item['fname'] + ' ' + item['lname'];
                              }
                            }
                            if (userpost == "") userpost = "ไม่ประสงค์จะออกนาม";
                            return Column(
                              
                              children: <Widget>[
                                Text(
                                  userpost,
                                  style: new TextStyle(
                                    fontSize: userSize,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold                   
                                  ),  
                                ),
                              ],
                            );
                          },),
                          Text(
                            place,
                            style: new TextStyle(
                              fontSize: placeSize,
                              color: Colors.black,           
                            ),  
                          ),

                          Text('โพสต์เมื่อ : ' + 
                            DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[widget.no]['dateCreated']).toIso8601String().toString().substring(0, 10) + ' ' +                                             
                            DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[widget.no]['dateCreated']).toIso8601String().toString().substring(11, 16)
                            ,
                            style: new TextStyle(
                              fontSize: 12.0,
                              color: Colors.blueGrey              
                            ),  
                          ),
                          ]
                      ), 
                          ]),

                          

                            Text("        "),
                            Container(
                              padding: EdgeInsets.all(20),
                              child: 
                              urlPicPost == null 
                              ? new Center(child: Image.asset('resources/logo.PNG', width: 150))
                              : new Center(child: Image.network(
                                urlPicPost,
                                width: 40,
                                height: 40,
                              ),)
                            ),

                            Container(
                            padding: EdgeInsets.all(20),
                            child: 
                              Text(
                                snapshot.data.documents[widget.no]['detail'],
                                style: new TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black              
                                ),  
                                overflow: TextOverflow.ellipsis, 
                                maxLines: 10,
                              ),
                            ),
                         

                        //   FlatButton(
                        //    padding: const EdgeInsets.all(8.0),
                        //    child: Text("กลับไปสู่หน้าฟีด"),
                        //    textColor: Colors.white,
                        //    color: Colors.green,
                        //    onPressed: () {
                        //      Navigator.pop(context);
                        //    }
                        //  ),
                        ],
                      )),
                     
                      Row (
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          new Container(
                            padding: EdgeInsets.only(top: 5.0),              
                            width: 180.0,
                            child: new TextField(         
                              keyboardType: TextInputType.text,
                              maxLines: 2,
                              controller: comment_Word,
                              style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.lightGreen                 
                              ),

                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                labelText: 'Write comment...',
                                prefixIcon: Container( 
                                  padding: EdgeInsets.all(3.0),
                                  child:
                                  userPic == null  || userPic == '' 
                                  ? new Image.asset('resources/logo.PNG', height: 30)
                                  : new Image.network(
                                    userPic,
                                    height: 30,
                                  ),
                                ),
                                // border: OutlineInputBorder()
                              ),
                            )
                          ),
                          RaisedButton(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Comment"),
                            textColor: Colors.white,
                            color: Colors.green,
                            onPressed: () {
                              //datas.collection('posts')
                              Firestore.instance.collection('posts').document(snapshot.data.documents[widget.no].documentID).collection('comments')
                              // snapshot.data.documents[i]['detail']
                              .add({
                                'dateCreated': DateTime.parse(DateTime.now().toString()).millisecondsSinceEpoch, 
                                'detail': comment_Word.text,
                                /* This is for Firebase Auth from login state 
                                Now I use Q's account */
                                'user' : '${widget.userId}',
                                /* This is for Photo Adding  */
                                'photo' : ["posts/GScRX892knG1XDvQFKjU/hello.jpg"]
                                }
                              );
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text('คอมเมนต์ดังกล่าวเรียบร้อยแล้ว'),
                              ));
                            }
                          ),
                        ],
                      ),
                      
                      Container(
                        child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('posts').document(snapshot.data.documents[widget.no].documentID).collection('comments').orderBy("dateCreated").snapshots(),
                        builder: (context, snapshot2) {
                            if(snapshot.data == null) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                              final children = <Widget>[];
                              for (var i = 0; i < snapshot2.data.documents.length; i++) {
                                children.add(
                                  Container(
                                    padding: EdgeInsets.only(top: 20.0), 
                                    margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                                    width: 300,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreen[200],
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        StreamBuilder<QuerySnapshot>(
                                          stream: Firestore.instance.collection('users').snapshots(),
                                          builder: (context, snapshot3) {
                                            String userpost = "";
                                            for (var item in snapshot3.data.documents) {
                                              if (item.documentID == snapshot2.data.documents[i]['user']) {
                                                userpost = item['fname'] + ' ' + item['lname'];
                                              }
                                            }
                                            if (userpost == "") userpost = "ไม่ประสงค์จะออกนาม";
                                            return Column(
                                              children: <Widget>[
                                                Text(
                                                  userpost,
                                                  style: new TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold                   
                                                  ),  
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        // Text('' + 
                                        
                                        //   snapshot2.data.documents[i]['user'],
                                        //   style: new TextStyle(
                                        //     fontSize: 12.0,
                                        //     color: Colors.lightGreen                 
                                        //   ),  
                                        // ),

                                        Image.asset(['photo'][0]),

                                        Text('โพสต์เมื่อ : ' + 
                                          DateTime.fromMillisecondsSinceEpoch(snapshot2.data.documents[i]['dateCreated']).toIso8601String().toString().substring(0, 10) + ' ' +                                             
                                          DateTime.fromMillisecondsSinceEpoch(snapshot2.data.documents[i]['dateCreated']).toIso8601String().toString().substring(11, 16)
                                          ,
                                          style: new TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.blueGrey              
                                          ),  
                                        ),

                                        Container(
                                          padding: EdgeInsets.only(left:10, right: 10),
                                          child: 
                                            Text(
                                              snapshot2.data.documents[i]['detail'],
                                              style: new TextStyle(
                                                fontSize: 18.0,
                                                color: Colors.black              
                                              ),  
                                              overflow: TextOverflow.ellipsis, 
                                              maxLines: 10,
                                            ),
                                          ),

                                        
                                        widget.userId == snapshot.data.documents[widget.no]['user']
                                        ? FlatButton(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text("ลบ"),
                                          textColor: Colors.white,
                                          color: Colors.red,
                                          onPressed: () {
                                            Firestore.instance.collection('posts').document(snapshot.data.documents[widget.no].documentID)
                                            .collection('comments').document(snapshot2.data.documents[i].documentID).delete();
                                            Scaffold.of(context).showSnackBar(new SnackBar(
                                              content: new Text('ลบคอมเมนต์ดังกล่าวเรียบร้อยแล้ว'),
                                            ));
                                          }
                                        )
                                        : Text('')
                                      ,
                                      ],
                                    ))
                                  );
                                  
                                  
                              }
                              return new Column(
                                children: children,
                              );
                                              
                        },
                      )
                    )
                  ]
                );           
                },
            )          
          ),           
          ],
        ),
        ]
      ),
    );
  }
}



import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitsbook/NewFeed/new_feed.dart';
import 'package:fitsbook/Profile.dart';
import 'package:fitsbook/Profile/ProfilePic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

int count;
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
DateTime _now = DateTime.now();
class CommentState extends State<Comment> {
  final Firestore _db = Firestore.instance;
  
  bool _isFinish;
  TextEditingController _comment = TextEditingController();
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

    void initState() {
      super.initState();
      _isFinish = false;
      count = 0;
    }
  }

  String urlUserPost;
  getUrlForPostUser(String userId) async {
    StorageReference ref = 
        FirebaseStorage.instance.ref().child("profile/$userId/profile");
    String url = (await ref.getDownloadURL()).toString();
    // print(url);
    if (url == null) url = 'https://upload.wikimedia.org/wikipedia/commons/d/d2/Question_mark.svg';
    setState(() {
      urlUserPost = url;
    });
  }

  // ดึงคอมเมนต์
  Future getAllComment(documentId) async {
    QuerySnapshot data = await _db.collection('posts').document(documentId).collection('comments').orderBy('dateCreated', descending: true).getDocuments();
    return data.documents;
  }
  
  @override
  Widget build(BuildContext context) {
    count++;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}"),
      ),
      body: 
      ListView(
        children: <Widget>[
          Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('posts').orderBy("dateCreated", descending: true).snapshots(),
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
                  userSize = 18;
                  placeSize = 0;
                } 
                else {
                  userSize = 12;
                  place = 'อยู่ที่ ' + snapshot.data.documents[widget.no]['place'];
                  if (place.length > 40) { place = place.substring(0, 40) + '...'; }
                } 
                      
                if (place == '') {
                  userSize = 18;
                  placeSize = 0;
                }

                
                return new 
                Column(
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
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(snapshot.data.documents[widget.no]['user']))),
                        child: new
                      Column(     
                        crossAxisAlignment: CrossAxisAlignment.start,                                     
                        children: <Widget>[
                          Row(children: <Widget>[

                          Text("        "),
                          Container(
                            width: 40,
                             child: GestureDetector(
                               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(snapshot.data.documents[widget.no]['user']))),
                               child: 
                                 urlUserPost == null || urlUserPost == '' 
                                 ? new ProfilePics(
                                   path: 'https://raw.githubusercontent.com/ingchoff/Fitsbook/master/resources/logo.PNG',
                                   diameter: 40,
                                 )
                                 : new ProfilePics(
                                   path: urlUserPost,
                                   diameter: 40,
                                 )
                             )
                           ),
                         
                          Text("   "),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          StreamBuilder<QuerySnapshot>(
                          stream: _db.collection('users').snapshots(),
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
                      ))),
                     
                      Row (
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          new Container(
                            padding: EdgeInsets.only(top: 5.0),              
                            width: 180.0,
                            child: new TextField(         
                              keyboardType: TextInputType.text,
                              maxLines: 2,
                              controller: _comment,
                              style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.black                 
                              ),

                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                labelText: 'Write comment...',
                                prefixIcon: Container(
                                  width: 15,
                                   child: GestureDetector(
                                     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(userId))),
                                     child: 
                                       userPic == null   || userPic == '' 
                                     ? new ProfilePics(
                                       path: 'https://raw.githubusercontent.com/ingchoff/Fitsbook/master/resources/logo.PNG',
                                       diameter: 30,
                                     )
                                     : new ProfilePics(
                                       path: userPic,
                                       diameter: 30,
                                     )
                                   )
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
                              _db.collection('posts').document(snapshot.data.documents[widget.no].documentID).collection('comments')
                              // snapshot.data.documents[i]['detail']
                              .add({
                                'dateCreated': DateTime.parse(DateTime.now().toString()).millisecondsSinceEpoch, 
                                'detail': _comment.text,
                                /* This is for Firebase Auth from login state 
                                Now I use Q's account */
                                'user' : '${widget.userId}',
                                // /* This is for Photo Adding  */
                                // 'photo' : ["posts/GScRX892knG1XDvQFKjU/hello.jpg"]
                                }
                              );
                              _comment.clear();
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                content: new Text('คอมเมนต์ดังกล่าวเรียบร้อยแล้ว'),
                              ));
                            }
                          ),
                        ],
                      ),
                      
                      Container(
                        margin: EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: 
                            FutureBuilder<dynamic>(
                              future: getAllComment(snapshot.data.documents[widget.no].documentID),
                              builder: (BuildContext context, AsyncSnapshot snapshot2) {
                                var allData = snapshot2.data;
                                if(allData == null) {  
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (allData.length == 0) {
                                  return Center(
                                    child: Text('No Comment !'),
                                  );
                                }
                                
                                
                                    // return SizedBox(
                                    //   width: 600,
                                    //   height: 400,
                                    //   child: 
                                    //   ListView.builder(
                                    //     itemBuilder: (BuildContext context, int i) {
                                          
                                    //     },
                                    //     itemCount: snapshot.data.length,
                                    //   ),
                                    // );
                                    final children = <Widget>[];
                                    // children.add(Text(snapshot.data.length.toString()));
                    
                                    for (var i = 0; i < snapshot2.data.length; i++) 
                                    { 
                                        // โยนค่ำเข้าฟังก์ชัน ให้รีเทิร์น URL
                                      String place = '';
                                          double userSize = 18;
                                          double placeSize = 10;
                                          double frameSize = 475;
                                          if (snapshot2.data[i]['place'] == null || snapshot2.data[i]['place'] == '') {
                                            userSize = 18;
                                            placeSize = 0;
                                          } 
                                          else {
                                            userSize = 12;
                                            place = 'อยู่ที่ ' + snapshot2.data[i]['place'];
                                            if (place.length > 40) { place = place.substring(0, 40) + '...'; }
                                          } 
                              
                                          if (place == '') {
                                            userSize = 18;
                                            placeSize = 0;
                                          }
                                          getUrlForPostUser(snapshot2.data[i]['user']);
                                          children.add (
                                            GestureDetector(
                                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(snapshot2.data[i]['user']))),
                                            child: 
                                            Container(
                                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0), 
                                              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, snapshot2.data.length != i ? 10.0 : 50.0),
                                              //width: 300,
                                              //height: frameSize,
                                              decoration: BoxDecoration(
                                                color: Colors.lightGreen[200],
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 2.0,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: 

                                              // รูปคนโพสต์
                                              Column(
                                                children: <Widget>[
                                                  Text("        "),
                                                  Row(                                          
                                                    children: <Widget>[
                                                      Text("        "),
                                                      Container(
                                                        width: 40,
                                                        child: GestureDetector(
                                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(snapshot2.data[i]['user']))),
                                                          child: 
                                                            urlUserPost == null || urlUserPost == '' 
                                                            ? new ProfilePics(
                                                              path: 'https://raw.githubusercontent.com/ingchoff/Fitsbook/master/resources/logo.PNG',
                                                              diameter: 40,
                                                            )
                                                            : new ProfilePics(
                                                              path: urlUserPost,
                                                              diameter: 40,
                                                            )
                                                        )
                                                      ),
                                                      Text("   "),

                                                      // ชื่อของคนโพสต์
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              StreamBuilder<QuerySnapshot>(
                                                                stream: _db.collection('users').snapshots(),
                                                                builder: (context, snapshot3) {
                                                                  if(snapshot3.hasData) {
                                                                    if(snapshot3.data.documents.length != 0) {
                                                                  String userpost = "";
                                                                  for (var item in snapshot3.data.documents) {
                                                                    if(item.documentID == snapshot2.data[i]['user']) {
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
                                                                }else return Text('');} else return Text('');
                                                                }
                                                                ),
                                                                Text('  ')
                                                                
                                                                
                                                              ]
                                                            ),
                                                            // สถานที่ที่เช็คอิน (ถ้ามี)
                                                            Text(
                                                              place,
                                                              style: new TextStyle(
                                                                fontSize: placeSize,
                                                                color: Colors.black,           
                                                              ),  
                                                            ),
                                                            // เวลาโพสต์
                                                            Text('โพสต์เมื่อ : ' + 
                                                              DateTime.fromMillisecondsSinceEpoch(snapshot2.data[i]['dateCreated']).toIso8601String().toString().substring(0, 10) + ' ' +                                             
                                                              DateTime.fromMillisecondsSinceEpoch(snapshot2.data[i]['dateCreated']).toIso8601String().toString().substring(11, 16)
                                                              ,
                                                              style: new TextStyle(
                                                                fontSize: 12.0,
                                                                color: Colors.blueGrey              
                                                              ),  
                                                            ),
                                                        ]
                                                      )
                                                    ],
                                                  ),
                                                  Text("        "),
                                                  // ช้อมูลของโพสต์
                                                  Container(
                                                    padding: EdgeInsets.only(left:10, right: 10),
                                                    child: 
                                                      Text(
                                                        snapshot2.data[i]['detail'] + '\n',
                                                        style: new TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors.black              
                                                        ),  
                                                        overflow: TextOverflow.ellipsis, 
                                                        maxLines: 10,
                                                      ),
                                                  ),
                                                  
                                                  // ปุ่มลบโพสต์
                                                  userId == snapshot2.data[i]['user']
                                                  ? FlatButton(
                                                    padding: const EdgeInsets.only(top: 5.0),
                                                    child: Text("ลบ"),
                                                    textColor: Colors.white,
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      _db.collection('posts').document(snapshot.data.documents[widget.no].documentID)
                                                      .collection('comments').document(snapshot2.data[i].documentID).delete();
                                                      Scaffold.of(context).showSnackBar(new SnackBar(
                                                        content: new Text('ลบคอมเมนต์ดังกล่าวเรียบร้อยแล้ว'),
                                                      ));
                                                      // _db.collection('posts').document(snapshot.data[i].documentID).delete();
                                                      // Scaffold.of(context).showSnackBar(new SnackBar(
                                                      //   content: new Text('ลบโพสต์ดังกล่าวเรียบร้อยแล้ว'),
                                                      // ));
                                                    }
                                                  )
                                                  : Text(''),
                                                ],
                                              )))
                                            ); 
                                      
                                      
                                    }
                                    return 
                                      
                                      new Column(
                                        children: children,
                                      );
                              }   
                            ),
                          // ListView.builder(
                            
                          // ),
                        ),
                      ),

                      
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



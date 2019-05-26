import 'dart:convert';
import 'dart:io';
import 'package:fitsbook/Chat/homepage.dart';
import 'package:fitsbook/PostScreen/ui/post_screen.dart';
import 'package:fitsbook/Profile.dart';
import './comment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class NewFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NewFeedState();
  }

}

String txt;
String userPic;
String userId;

class NewFeedState extends State<NewFeed> {
  
  final Firestore _db = Firestore.instance;
 
  @override
  void initState(){
    super.initState();
    // สำหรับเรียกภาพผู้ใช้ตอนโพสต์
    readFile('profile').then((String value){
      userPic = value;
    });

    readFile('userId').then((String value){
      userId = value;
    });

  }

  final TextEditingController comment_Word = TextEditingController();

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

  String picPost;
  Future<String> picturePath(documentId) async {
    var eachPost = await _db.collection('posts').document(documentId).get();
    setState(() {
      picPost = eachPost.data['photo']; 
    });
    return picPost;
  }
  
  String txt2;
  getUrl(path) async {
    StorageReference ref = 
        FirebaseStorage.instance.ref().child("$path");
    String url = (await ref.getDownloadURL()).toString();
    // print(url);
    setState(() {
      txt2 = url;
    });
  }

  // ดึงรูปโพสต์ (ฟังก์ชันทำงานผิดปรกติ)
  String urlPicPost;
  getUrlForPost(String documentID) async {
    StorageReference ref = 
        FirebaseStorage.instance.ref().child('posts/${documentID}/post');
    String url = (await ref.getDownloadURL()).toString();
    // print(url);
    setState(() {
      urlPicPost = url;
    }); 
  }

  // ดึงรูปคนโพสต์ (ฟังก์ชันทำงานผิดปรกติ)
  String urlUserPost;
  getUrlForPostUser(String userId) async {
    StorageReference ref = 
        FirebaseStorage.instance.ref().child("profile/$userId/profile");
    String url = (await ref.getDownloadURL()).toString();
    // print(url);
    setState(() {
      urlUserPost = url;
    });
    return url;
  }

  // ดึงโพสต์
  Future getAllPost() async {
    QuerySnapshot data = await _db.collection('posts').orderBy('dateCreated', descending: true).getDocuments();
    return data.documents;
  }

  // ดึงคอมเมนต์
  Future getAllComment(documentId) async {
    QuerySnapshot data = await _db.collection('posts').document(documentId).collection('comments').orderBy('dateCreated', descending: true).getDocuments();
    return data.documents;
  }
  

  @override
  Widget build(BuildContext context) {
    debugPrint(userId);
    // printUrl();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('resources/logo.PNG', fit: BoxFit.cover, width: 25,)
        )
        
      ),
      body: ListView(
        children: [ Container(
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              /* This is a part of posting new feed. */
              Row (
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  new Expanded(
                    // margin: EdgeInsets.only(top: 24.0),              
                    // //width: 300.0,
                    // decoration: BoxDecoration(
                    //   color: Colors.lightGreen[200],
                    //   border: Border.all(
                    //     color: Colors.black,
                    //     width: 2.0,
                    //   ),
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    child: 
                      new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        userPic == null   || userPic == ''  || userPic == ''
                        ? new Image.asset('resources/logo.PNG', height: 30)
                        : new Image.network(
                          userPic,
                          height: 30,
                        ),
                        Text('คุณกำลังคิดอะไรอยู่ ?', style: TextStyle(fontSize: 16),),
                        RaisedButton(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("บอกให้เรารู้"),
                          textColor: Colors.white,
                          color: Colors.green,
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PostForm()));
                          }
                        ),
                      ],
                    )
                  )
                ],
              ),
              
              // วนลูปโพสต์ เพื่อแสดงโพสต์
              Container(
                child: Center(
                  child: 
                    FutureBuilder<dynamic>(
                      future: getAllPost(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if(snapshot.hasData) {
                          if(snapshot.data.length != 0) {
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
            
                            for (var i = 0; i < snapshot.data.length; i++) 
                            { 
                                // โยนค่ำเข้าฟังก์ชัน ให้รีเทิร์น URL
                              String place = '';
                                  double userSize = 18;
                                  double placeSize = 10;
                                  double frameSize = 475;
                                  if (snapshot.data[i]['place'] == null || snapshot.data[i]['place'] == '') {
                                    userSize = 18;
                                    placeSize = 0;
                                  } 
                                  else {
                                    userSize = 12;
                                    place = 'อยู่ที่ ' + snapshot.data[i]['place'];
                                    if (place.length > 40) { place = place.substring(0, 40) + '...'; }
                                  } 
                      
                                  if (place == '') {
                                    userSize = 18;
                                    placeSize = 0;
                                  }
                                  getUrlForPost(snapshot.data[i].documentID);  
                                  getUrlForPostUser(snapshot.data[i]['user']);
                                  children.add (
                                    GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(snapshot.data[i]['user']))),
                                    child: 
                                    Container(
                                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0), 
                                      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, snapshot.data.length != i ? 10.0 : 50.0),
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
                                              urlUserPost == null || urlUserPost == ''
                                              ? new Image.asset('resources/logo.PNG', fit: BoxFit.cover, width: 25,)
                                              : new Image.network(
                                                urlUserPost,
                                                width: 40,
                                                height: 40,
                                              ),
                                              Text("   "),

                                              // ชื่อของคนโพสต์
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      StreamBuilder<QuerySnapshot>(
                                                        stream: Firestore.instance.collection('users').snapshots(),
                                                        builder: (context, snapshot2) {
                                                          String userpost = "";
                                                          for (var item in snapshot2.data.documents) {
                                                            if(item.documentID == snapshot.data[i]['user']) {
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
                                                        Text('  '),
                                                        
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
                                                      DateTime.fromMillisecondsSinceEpoch(snapshot.data[i]['dateCreated']).toIso8601String().toString().substring(0, 10) + ' ' +                                             
                                                      DateTime.fromMillisecondsSinceEpoch(snapshot.data[i]['dateCreated']).toIso8601String().toString().substring(11, 16)
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
                                                snapshot.data[i]['detail'] + '\n',
                                                style: new TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.black              
                                                ),  
                                                overflow: TextOverflow.ellipsis, 
                                                maxLines: 10,
                                              ),
                                          ),
                                          // รูปโพสต์
                                          urlPicPost == null || urlPicPost == ''
                                          ? new Image.asset('resources/logo.PNG', width: 125)
                                          : new Image.network(
                                            urlPicPost,
                                            width: 125,
                                            height: 200,
                                          ),
                                          // กดดูคอมเมนต์
                                          Row(          
                                            mainAxisAlignment: MainAxisAlignment.end,                                
                                            children: <Widget>[
                                              FlatButton(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text("View Comments"),
                                                textColor: Colors.green,
                                                // color: Colors.green,
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Comment(title: snapshot.data[i]['detail'],no: i,
                                                  userPic: userPic, userId: userId)));
                                                }
                                              ),
                                              Text("    "),
                                            ]
                                          ),
                                          // ที่สำหรับเขียน Comment
                                          Row (
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              
                                              new Container(
                                                padding: EdgeInsets.only(top: 5.0),              
                                                width: 180.0,
                                                child: new TextField(         
                                                  keyboardType: TextInputType.text,
                                                  maxLines: 2,
                                                  
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
                                                  _db.collection('posts').document(snapshot.data[i].documentID).collection('comments')
                                                  // snapshot.data.documents[i]['detail']
                                                  .add({
                                                    'dateCreated': DateTime.parse(DateTime.now().toString()).millisecondsSinceEpoch, 
                                                    'detail': comment_Word.text,
                                                    /* This is for Firebase Auth from login state 
                                                    Now I use Q's account */
                                                    'user' : '$userId',
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

                                          Row (
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              
                                            ],
                                          ),
                                          // ปุ่มลบโพสต์
                                          userId == snapshot.data[i]['user']
                                          ? FlatButton(
                                            padding: const EdgeInsets.only(top: 5.0),
                                            child: Text("ลบ"),
                                            textColor: Colors.white,
                                            color: Colors.red,
                                            onPressed: () {
                                              Firestore.instance.collection('posts').document(snapshot.data[i].documentID).delete();
                                              Scaffold.of(context).showSnackBar(new SnackBar(
                                                content: new Text('ลบโพสต์ดังกล่าวเรียบร้อยแล้ว'),
                                              ));
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
                          else {
                            return Center(child: CircularProgressIndicator());
                          }
                        }
                        else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }
                      
                    ),
                  // ListView.builder(
                    
                  // ),
                ),
              )
            ], 
            ),
          ), ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        },
        child: Icon(Icons.chat),
      ),
    );
  }
}

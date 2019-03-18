import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TestForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestFormState();
  }
}

class TestFormState extends State{
  final _formKey = GlobalKey<FormState>();
  String post;
  List<File> _image;

  Future getImageCamera() async { //ฟังชั่นถ่ายรูป
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState((){
      _image.add(image);
    });
  }

  Future getImageGallery() async { //ฟังชั่นอัพโหลดรูป
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState((){
      _image.add(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        // title: Text("โพสต์")
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            OutlineButton( //หัวเรื่อง
                child: Text(
                  "สร้างโพสต์",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                  ),
                ),
                onPressed: null,
                shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0))
              ),

            TextFormField( //TextFormField ของโพสต์
                decoration: InputDecoration(
                  // labelText: "สร้างโพสต์",
                  hintText: "คุณกำลังคิดอะไรอยู่?",
                //   icon: Image.asset(
                //   "resources/Caterpie.png",
                //   height: 30,
                // ),
                  contentPadding: new EdgeInsets.symmetric(vertical: 20.0),
                ),
                maxLines: null,
                // keyboardType: TextInputType.multiline,
                validator: (post) {
                  if (post.isEmpty) {
                    this.post = "";
                    return "โพสต์ของคุณว่างเปล่า";
                  } else {
                    this.post = post;
                  }
                }),

            Container( //รูป
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: _image == null ? Image.asset("resources/noimage.jpg",height: 100,)
              : Image.file(_image[0]),
              alignment: FractionalOffset.bottomLeft,
            ),

            Row( //แถวสำหรับปุ่ม ถ่ายรูป และ อัพโหลดรูป
              children: <Widget>[
                Container( //ถ่ายรูป
                  alignment: FractionalOffset.bottomLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: OutlineButton(
                    child: Column( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Icon(Icons.add_a_photo),
                        // Text("Add image")
                      ],
                    ),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                    onPressed: () {
                      getImageCamera();
                    },
                  ),
                ),
                Container( //อัพโหลดรูป
                  alignment: FractionalOffset.bottomLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: OutlineButton(
                    child: Column( // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Icon(Icons.file_upload),
                        // Text("Add image")
                      ],
                    ),
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                    onPressed: () {
                      getImageGallery();
                    },
                  ),
                ),
              ],
            ),
            
            Container( //สำหรับปุ่มแชร์
              alignment: FractionalOffset.bottomRight,
              child: RaisedButton(
                child: Text("แชร์", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                  ),),
                color: Colors.blue,
                onPressed: () {
                  // _formKey.currentState.validate();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

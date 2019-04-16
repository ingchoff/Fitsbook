import 'package:flutter/material.dart';

class ProfilePics extends StatelessWidget {
  final double diameter;
  final String path;

  ProfilePics({this.diameter, this.path});

  @override
  Widget build(BuildContext context) {
    // error handling
    NetworkImage image;
    if (path != null) {
      image = NetworkImage(path);
    } else {
      String holder = '''https://firebasestorage.googleapis.com/v0/b/fitsbook-social.appspot.com/o/profile%2Fprofile-placeholder.png?alt=media&token=e62f8d1a-1a96-4632-b249-0f436c9418b3''';
      image = NetworkImage(holder);
    }

    // เอาไว้สร้างรูปโปรไฟล์
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: image,
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(80.0)),
      ),
    );
  }
}

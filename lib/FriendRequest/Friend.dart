import 'package:flutter/material.dart';
import '../Profile/ProfilePic.dart';

class Friend extends StatelessWidget {
  final String profilePath;
  final String dname;

  Friend({this.profilePath, this.dname});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: ProfilePics(
                    path: profilePath,
                    diameter: 50,
                  ),
                ),
                Text(
                  dname,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

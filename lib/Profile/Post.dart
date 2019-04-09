import 'package:flutter/material.dart';

class ProfilePosts extends StatelessWidget {
  final Widget profile;
  final String dname;
  final String detail;
  final int date;

  ProfilePosts({this.profile, this.dname, this.detail, this.date});

  @override
  Widget build(BuildContext context) {
    double cwidth = MediaQuery.of(context).size.width * 0.8;

    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        child: profile,
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Text(
                        dname,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ],
                  ),
                  Text(
                    DateTime
                      .fromMillisecondsSinceEpoch(date)
                      .toString()
                      .substring(0, 16)
                  )
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  width: cwidth,
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

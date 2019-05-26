import 'package:flutter/material.dart';

class FeatureList extends StatefulWidget {
  @override
  FeatureListState createState() {
    return FeatureListState();
  }
}

class FeatureListState extends State<FeatureList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    // This also removes the _printLatestValue listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20,bottom: 20),
            child: ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Login & Register with Firebase',style: TextStyle(fontSize: 18)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0,bottom: 20),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile & Edit Profile',style: TextStyle(fontSize: 18)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0,bottom: 20),
            child: ListTile(
              leading: Icon(Icons.insert_comment),
              title: Text('Posts & Comments',style: TextStyle(fontSize: 18)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0,bottom: 20),
            child: ListTile(
              leading: Icon(Icons.people),
              title: Text('Add Friend',style: TextStyle(fontSize: 18),),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0,bottom: 20),
            child: ListTile(
              leading: Icon(Icons.map),
              title: Text('Map & Check-in',style: TextStyle(fontSize: 18)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0,bottom: 20),
            child: ListTileTheme(
              selectedColor: Colors.teal,
              child: ListTile(
                leading: Icon(Icons.chat),
                title: Text('Chat',style: TextStyle(fontSize: 18)),
              ),
            )
          ),
        ],
      )
    );
  }
}
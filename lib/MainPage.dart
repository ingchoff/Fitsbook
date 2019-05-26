import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsbook/FeatureList.dart';
import 'package:fitsbook/FriendRequest.dart';
import 'package:fitsbook/FriendRequest/RequestList.dart';
import 'package:fitsbook/Map.dart';
import 'package:flutter/material.dart';
import './Holder.dart';
import './NewFeed/new_feed.dart';
import './Profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key key,
    @required this.user
  }) : super(key: key);
  final FirebaseUser user;
  
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  int index = 0;
  List<Widget> _children = [
      NewFeed(),
      FriendRequest(),
      Profile(),
      FeatureList()
    ];

  void _navHandler(int index) {
    setState(() {
      this.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Theme.of(context).primaryColor,
          ),
          child: BottomNavigationBar(
            currentIndex: index,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), 
                  title: Text('Home')),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                title: Text('Notifications'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text('Profile')
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.featured_play_list),
                title: Text('Feature List')
              ),
            ],
            onTap: _navHandler,
          ),
        ),
        body: _children[index]);
  }
}

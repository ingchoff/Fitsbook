import 'package:firebase_auth/firebase_auth.dart';
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
      Holder('Notify'),
      Holder('Map'),
      Profile(),
      Holder('Settings')
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
                  icon: Icon(Icons.home), title: Text('Home')),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                title: Text('Notifications'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                title: Text('map')
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text('Profile')
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                title: Text('Setting')
              ),
            ],
            onTap: _navHandler,
          ),
        ),
        body: _children[index]);
  }
}

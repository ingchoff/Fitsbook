import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:flutter/services.dart';

class LocationForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LocationFormState();
  }
}

class LocationFormState extends State {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
        home: new Scaffold(
      appBar: AppBar(
        title: Text('Location'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Lat/Lng: ${currentLocation["latitude"]} / ${currentLocation["longitude"]}',
              style: TextStyle(fontSize: 20.0, color: Colors.blueAccent),
            )
          ],
        ),
      ),
    ));
  }

  Map<String, double> currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  Location location = new Location();
  String error;

  @override
  void initState() {
    super.initState();

    //default var set 0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;

    initPlatformState();
    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        currentLocation = result;
      });
    });
  }

  void initPlatformState() async {
    Map<String, double> my_location;

    try {
      my_location = await location.getLocation();
      error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app setting';
      }
      my_location = null;
    }

    setState(() {
      currentLocation = my_location;
    });
  }
}

import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/place_model.dart';
import '../services/place_service.dart';
import './post_screen.dart';
import 'package:flutter/material.dart';

class PlacesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PlacesScreenState();
  }
}

class PlacesScreenState extends State<PlacesScreen> {
  GoogleMapController _controller;
  List<Marker> allMarkers = [];
  Set<Marker> _marker = Set();
  static String address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Places"),
      ),
      body: _createContent(),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
  }

  _addMarker(LatLng point) {
    String latLng = (point.latitude.toString() + ',' + point.longitude.toString());
    http.get('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latLng&key=AIzaSyDRFtRyNvn2LfONpJiMxrPr9FcBaIybwdk')
    .then((response) {
      // print(response.body);
      print(jsonDecode(response.body)['results'][0]['formatted_address']);
      // print(json.decode(response.body)[1].results);
      setState(() {
        address = jsonDecode(response.body)['results'][0]['formatted_address'];
      });
    });
    setState(() {
      _marker.clear();
      _marker.add(Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          infoWindow: InfoWindow(
          title: 'I am a marker',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      )
      );
    });
  }

  Widget _createContent() {
    if (_places == null) {
      return Center(
        child: CircularProgressIndicator(), //ระหว่างหาสถานที่จะแสดงหน้าโหลด
      );
    } else {
      List<Widget> placeList = [];
        placeList.add(
          Text(address)
        );
        placeList.add(
          SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: LatLng(40.7128, -74.0060), zoom: 12.0),
                    markers: _marker,
                    onMapCreated: mapCreated,
                    onTap: _addMarker,
                  ),
                ),
                ]
              ),
            ),
        );
<<<<<<< HEAD
        // placeList.add(
        //   Text()
        // );
=======
        placeList.add(
          Text('')
        );
>>>>>>> 18b28b81edc6901681c3fbb867d2be25c2021f17
        for (dynamic i in _places) {
        placeList.add(
          Card(
              child: ListTile(
              title: Text(i.name),
              leading: Image.network(i.icon),
              subtitle: Text(i.vicinity),
              onTap: (){
                handleTap(i);
              },
            ))
          );
        }
      return  ListView(
        children: placeList
      );
    }
  }

  handleTap(Place place){
    PostFormState.tagged = place.name; //เซ็ตชื่อสถานที่หลังจากกดใน PostFormState
    Navigator.pop(context,true);
  }

  List<Place> _places;

  @override
  void initState() {
    super.initState();
    // _marker.add(Marker(
    //   markerId: MarkerId(LatLng(40.7128, -74.0060).toString()),
    //   position: LatLng(40.7128, -74.0060),
    //   infoWindow: InfoWindow(
    //   title: 'I am a marker',
    // )
    // ));
    PlacesService.get().getNearbyPlaces().then((data) {
      this.setState(() {
        _places = data;
      });
    });
  }
}

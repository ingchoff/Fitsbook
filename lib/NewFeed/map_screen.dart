import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final double map_lat;
  final double map_long;
  List<Marker> allMarkers = [];

  MapScreen({this.map_lat, this.map_long});

  // @override
  // void init() {
  //   // TODO: implement initState
  //   super.init();
  //   allMarkers.add(Marker(
  //       markerId: MarkerId('Marker'),
  //       draggable: true,
  //       onTap: () {
  //         print('Marker Tapped');
  //       },
  //       position: LatLng(13.7265887, 100.774959)));
  // }

  List<Marker> addMarker(){
  allMarkers.add(Marker(
        markerId: MarkerId('Marker'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(map_lat, map_long)));
    return allMarkers;
}   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map"),
      ),
      body: map_lat == 0.0 && map_long == 0.0? Center(child: Text("This post doesn't allow location detector"),) : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(map_lat, map_long), 
          zoom: 15
          ),
        mapType: MapType.normal,
        markers: Set.from(addMarker()),
      ),
    );
  }
}

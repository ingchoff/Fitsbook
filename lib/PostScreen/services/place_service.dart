import '../models/place_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


class PlacesService{
  static double lat;
  static double long;
  static PlacesService _service = PlacesService();
  static PlacesService get(){
    return _service;
  }

  String searchUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${lat},${long}&radius=500&key=AIzaSyCZcVzn8YyqmxAXBciGh5gTDZG4rkSL9jg";

  Future<List<Place>> getNearbyPlaces() async{
    var response = await http.get(searchUrl, headers:{"Accept":"application/json"});
    var places = <Place>[];

    List data = json.decode(response.body)["results"];
    data.forEach((f) => places.add(Place(f["icon"], f["name"], f["vicinity"], f["id"])));

    return places;
  }
}
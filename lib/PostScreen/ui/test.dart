import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TestForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TestFormState();
  }
}

class TestFormState extends State{

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static const nycLat = 37.4219983;
  static const nyLng = -122.084;
  static const apiKey = 'AIzaSyCZcVzn8YyqmxAXBciGh5gTDZG4rkSL9jg';

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    print(await searchNearBy());
  }

  Future<List<String>> searchNearBy() async {
    var dio = Dio();
    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
    var parameters = {
      'key': apiKey,
      'location': '$nycLat,$nyLng',
      'radius': '800',
    };

    var response = await dio.get(url, data:parameters);
    return response.data['results']
    .map<String>((result) => result['name'].toString())
    .toList();
  }
}
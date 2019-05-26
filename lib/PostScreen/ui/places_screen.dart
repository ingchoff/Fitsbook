import '../models/place_model.dart';
import '../services/place_service.dart';
import './post_screen.dart';
import 'package:flutter/material.dart';

class PlacesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PlacesScreenState();
  }
}

class PlacesScreenState extends State<PlacesScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Places"),
      ),
      body: _createContent(),
    );
  }

  Widget _createContent() {
    if (_places == null) {
      return Center(
        child: CircularProgressIndicator(), //ระหว่างหาสถานที่จะแสดงหน้าโหลด
      );
    } else {
      return ListView(
        children: _places.map((f) {
          return Card(
              child: ListTile(
            title: Text(f.name),
            leading: Image.network(f.icon),
            subtitle: Text(f.vicinity),
            onTap: (){
              handleTap(f);
            },
          ));
        }).toList(),
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

    PlacesService.get().getNearbyPlaces().then((data) {
      this.setState(() {
        _places = data;
      });
    });
  }
}

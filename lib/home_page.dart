import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'camera_page.dart';
import 'entities/camera.dart';
import 'entities/neighbourhood.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = 'StreetCams';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<Camera> _parseCameraJson(String jsonString) {
  List<dynamic> jsonArray = json.decode(jsonString);
  return jsonArray.map((e) => Camera.fromJson(e)).toList();
}

List<Neighbourhood> _parseNeighbourhoodJson(String jsonString) {
  List<dynamic> jsonArray = json.decode(jsonString)['features'];
  return jsonArray.map((e) => Neighbourhood.fromJson(e)).toList();
}

Future<List<Camera>> _downloadCameraList() async {
  var url = Uri.parse('https://traffic.ottawa.ca/beta/camera_list');
  return compute(_parseCameraJson, await http.read(url));
}

Future<List<Neighbourhood>> _downloadNeighbourhoodList() async {
  var url = Uri.parse(
      'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson');
  return compute(_parseNeighbourhoodJson, await http.read(url));
}

class _MyHomePageState extends State<MyHomePage> {
  List<Camera> cameras = [];
  List<Neighbourhood> neighbourhoods = [];

  @override
  void initState() {
    _downloadCameraList().then((value) {
      setState(() {});
    });
    super.initState();
  }

  void sortCameras() {
    double lat = 45.454545;
    double lon = -75.696969;
    cameras.sort((a, b) =>
        Geolocator.distanceBetween(lat, lon, a.location.lat, a.location.lon)
            .compareTo(Geolocator.distanceBetween(
                lat, lon, b.location.lat, b.location.lon)));
    setState(() {});
  }

  void showRandomCamera() {
    _showCameras([cameras[Random().nextInt(cameras.length)]]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(BilingualObject.getAppName()),
        actions: [
          IconButton(
            onPressed: sortCameras,
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch to map view',
          ),
          IconButton(
            onPressed: sortCameras,
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by distance',
          ),
          IconButton(
            onPressed: sortCameras,
            icon: const Icon(Icons.favorite),
            tooltip: 'View favourites',
          ),
          IconButton(
            onPressed: sortCameras,
            icon: const Icon(Icons.visibility_off),
            tooltip: 'View hidden',
          ),
          IconButton(
            onPressed: showRandomCamera,
            icon: const Icon(Icons.casino),
            tooltip: 'Random camera',
          ),
          IconButton(
            onPressed: sortCameras,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Shuffle',
          ),
          IconButton(
            onPressed: sortCameras,
            icon: const Icon(Icons.dark_mode),
            tooltip: 'Dark mode',
          ),
        ],
      ),
      body: FutureBuilder<List<Camera>>(
        future: _downloadCameraList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            if (cameras.isEmpty) {
              cameras = snapshot.data ?? cameras;
              cameras.sort(
                  (a, b) => a.getSortableName().compareTo(b.getSortableName()));
            }
            return ListView.builder(
              itemCount: cameras.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(cameras[i].getName()),
                  onTap: () {
                    _showCameras([cameras[i]]);
                  },
                  onLongPress: () {
                    print('long press');
                  },
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _showCameras(List<Camera> cameras) {
    Navigator.pushNamed(
      context,
      CameraPage.routeName,
      arguments: cameras,
    );
  }
}

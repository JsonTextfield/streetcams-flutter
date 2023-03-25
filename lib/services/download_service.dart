import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../entities/camera.dart';
import '../entities/neighbourhood.dart';

class DownloadService {
  static Future<List<Camera>> downloadCameras() async {
    Uri url = Uri.parse('https://traffic.ottawa.ca/beta/camera_list');
    return compute(_parseCameraJson, await http.read(url));
  }

  static List<Camera> _parseCameraJson(String jsonString) {
    List jsonArray = json.decode(jsonString);
    return jsonArray.map((json) => Camera.fromJson(json)).toList()
      ..sort((a, b) => a.sortableName.compareTo(b.sortableName));
  }

  static Future<List<Neighbourhood>> downloadNeighbourhoods() async {
    Uri url = Uri.parse(
      'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson',
    );
    return compute(_parseNeighbourhoodJson, await http.read(url));
  }

  static List<Neighbourhood> _parseNeighbourhoodJson(String jsonString) {
    List jsonArray = json.decode(jsonString)['features'];
    return jsonArray.map((json) => Neighbourhood.fromJson(json)).toList();
  }

  static Future<List<Camera>> downloadAll() async {
    var cameras = await downloadCameras();
    cameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));

    var neighbourhoods = await downloadNeighbourhoods();

    for (var camera in cameras) {
      for (var neighbourhood in neighbourhoods) {
        if (neighbourhood.containsCamera(camera)) {
          camera.neighbourhood = neighbourhood.name;
        }
      }
    }
    return cameras;
  }
}

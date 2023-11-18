import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../entities/camera.dart';
import '../entities/city.dart';
import '../entities/neighbourhood.dart';

class DownloadService {
  static Future<List<String>> getHtmlImages(String url) async {
    String data = await http.read(Uri.parse(url));
    RegExp regex = RegExp('cameraimages/.*?"');
    return regex.allMatches(data).map((RegExpMatch match) {
      String str = match.group(0)!.replaceAll('"', '');
      int time = DateTime.now().millisecondsSinceEpoch;
      return 'https://trafficcams.vancouver.ca/$str?timems=$time';
    }).toList();
  }

  static Future<List<Camera>> downloadCameras(City city) async {
    String url = switch (city) {
      City.ottawa => 'https://traffic.ottawa.ca/beta/camera_list',
      City.toronto =>
        'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/a3309088-5fd4-4d34-8297-77c8301840ac/resource/4a568300-c7f8-496d-b150-dff6f5dc6d4f/download/Traffic%20Camera%20List.geojson',
      City.montreal =>
        'https://ville.montreal.qc.ca/circulation/sites/ville.montreal.qc.ca.circulation/files/cameras-de-circulation.json',
      City.calgary => 'https://data.calgary.ca/resource/k7p9-kppz.json',
      City.vancouver =>
        'https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/web-cam-url-links/exports/json?lang=en&timezone=America%2FNew_York',
      City.surrey =>
        'https://data.surrey.ca/datastore/dump/18b8fdab-bbb4-41c7-9f1a-37794cb1b883?format=json',
      City.ontario => 'https://511on.ca/api/v2/get/cameras',
      City.alberta => 'https://511.alberta.ca/api/v2/get/cameras',
    };

    return compute(_parseCameraJson, [city, await http.read(Uri.parse(url))]);
  }

  static List<Camera> _parseCameraJson(List<dynamic> data) {
    City city = data.first;
    String jsonString = data.last;
    List<dynamic> jsonArray = [];

    switch (city) {
      case City.toronto:
      case City.montreal:
        Map<String, dynamic> jsonObject = json.decode(jsonString);
        jsonArray = jsonObject['features'];
        break;
      case City.surrey:
        Map<String, dynamic> jsonObject = json.decode(jsonString);
        jsonArray = jsonObject['records'];
        break;
      case City.calgary:
      case City.ottawa:
      case City.vancouver:
      case City.ontario:
      default:
        jsonArray = json.decode(jsonString);
        break;
    }
    return jsonArray
        .where((json) =>
            (city != City.ontario && city != City.alberta) ||
            'Enabled' == json['Status'])
        .map((json) => Camera.fromJson(json, city))
        .toList();
  }

  static Future<List<Neighbourhood>> downloadNeighbourhoods(City city) async {
    String url = '';
    switch (city) {
      case City.surrey:
        return compute(_parseNeighbourhoodJson, [
          city,
          await rootBundle.loadString('assets/surrey_city_boundary.json'),
        ]);
      case City.toronto:
        url =
            'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/neighbourhoods/resource/1d38e8b7-65a8-4dd0-88b0-ad2ce938126e/download/Neighbourhoods.geojson';
        break;
      case City.montreal:
        url =
            'https://donnees.montreal.ca/dataset/f38c91a1-e33f-4475-a112-3b84b1c60c1e/resource/a80e611f-5336-4306-ba2a-fd657f0f00fa/download/quartierreferencehabitation.geojson';
        break;
      case City.calgary:
        url = 'https://data.calgary.ca/resource/surr-xmvs.json';
        break;
      case City.ottawa:
        url =
            'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson';
        break;
      case City.vancouver:
      case City.alberta:
      case City.ontario:
        return [];
    }
    return compute(_parseNeighbourhoodJson, [
      city,
      await http.read(Uri.parse(url)),
    ]);
  }

  static List<Neighbourhood> _parseNeighbourhoodJson(List<dynamic> data) {
    City city = data.first;
    String jsonString = data.last;
    List<dynamic> jsonArray = [];

    switch (city) {
      case City.calgary:
        jsonArray = json.decode(jsonString);
        break;
      case City.ottawa:
      case City.toronto:
      case City.montreal:
      case City.surrey:
      case City.ontario:
      default:
        jsonArray = json.decode(jsonString)['features'];
        break;
    }
    return jsonArray
        .where((json) {
          if (city == City.surrey) {
            Map<String, dynamic> properties = json['properties'];
            return properties['BOUNDARY_TYPE'] == 1;
          }
          return true;
        })
        .map((json) => Neighbourhood.fromJson(json, city))
        .toList();
  }
}

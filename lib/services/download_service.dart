import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../entities/Cities.dart';
import '../entities/camera.dart';
import '../entities/neighbourhood.dart';

class DownloadService {
  static Future<List<Camera>> downloadCameras(Cities city) async {
    String ottawaUrl = 'https://traffic.ottawa.ca/beta/camera_list';
    String montrealUrl =
        'https://ville.montreal.qc.ca/circulation/sites/ville.montreal.qc.ca.circulation/files/cameras-de-circulation.json';
    String torontoUrl =
        'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/a3309088-5fd4-4d34-8297-77c8301840ac/resource/4a568300-c7f8-496d-b150-dff6f5dc6d4f/download/Traffic%20Camera%20List.geojson';
    String calgaryUrl = 'https://data.calgary.ca/resource/k7p9-kppz.json';
    Uri url;
    switch (city) {
      case Cities.toronto:
        url = Uri.parse(torontoUrl);
        break;
      case Cities.montreal:
        url = Uri.parse(montrealUrl);
        break;
      case Cities.calgary:
        url = Uri.parse(calgaryUrl);
        break;
      case Cities.ottawa:
      default:
        url = Uri.parse(ottawaUrl);
        break;
    }
    return compute(_parseCameraJson, [city, await http.read(url)]);
  }

  static List<Camera> _parseCameraJson(List<dynamic> arguments) {
    Cities city = arguments.first as Cities;
    switch (city) {
      case Cities.toronto:
        Map<String, dynamic> jsonObject = json.decode(arguments.last as String);
        List jsonArray = jsonObject['features'] as List;
        return jsonArray.map((json) => Camera.fromJsonToronto(json)).toList()
          ..sort((a, b) => a.sortableName.compareTo(b.sortableName));
      case Cities.montreal:
        Map<String, dynamic> jsonObject = json.decode(arguments.last as String);
        List jsonArray = jsonObject['features'] as List;
        return jsonArray.map((json) => Camera.fromJsonMontreal(json)).toList()
          ..sort((a, b) => a.sortableName.compareTo(b.sortableName));
      case Cities.calgary:
        List<dynamic> jsonArray = json.decode(arguments.last as String);
        return jsonArray.map((json) => Camera.fromJsonCalgary(json)).toList()
          ..sort((a, b) => a.sortableName.compareTo(b.sortableName));
      case Cities.ottawa:
      default:
        List jsonArray = json.decode(arguments.last as String) as List;
        return jsonArray.map((json) => Camera.fromJsonOttawa(json)).toList()
          ..sort((a, b) => a.sortableName.compareTo(b.sortableName));
    }
  }

  static Future<List<Neighbourhood>> downloadNeighbourhoods(Cities city) async {
    String ottawaUrl =
        'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson';
    String montrealUrl =
        'https://donnees.montreal.ca/dataset/f38c91a1-e33f-4475-a112-3b84b1c60c1e/resource/a80e611f-5336-4306-ba2a-fd657f0f00fa/download/quartierreferencehabitation.geojson';
    String torontoUrl =
        'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/neighbourhoods/resource/1d38e8b7-65a8-4dd0-88b0-ad2ce938126e/download/Neighbourhoods.geojson';
    String calgaryUrl = 'https://data.calgary.ca/resource/surr-xmvs.json';
    Uri url;
    switch (city) {
      case Cities.toronto:
        url = Uri.parse(torontoUrl);
        break;
      case Cities.montreal:
        url = Uri.parse(montrealUrl);
        break;
      case Cities.calgary:
        url = Uri.parse(calgaryUrl);
        break;
      case Cities.ottawa:
      default:
        url = Uri.parse(ottawaUrl);
        break;
    }
    return compute(_parseNeighbourhoodJson, [city, await http.read(url)]);
  }

  static List<Neighbourhood> _parseNeighbourhoodJson(List<dynamic> arguments) {
    Cities city = arguments.first as Cities;
    String jsonString = arguments.last as String;
    switch (city) {
      case Cities.toronto:
        List jsonArray = json.decode(jsonString)['features'];
        return jsonArray
            .map((json) => Neighbourhood.fromJsonToronto(json))
            .toList();
      case Cities.montreal:
        List jsonArray = json.decode(jsonString)['features'];
        return jsonArray
            .map((json) => Neighbourhood.fromJsonMontreal(json))
            .toList();
      case Cities.calgary:
        List jsonArray = json.decode(jsonString);
        return jsonArray
            .map((json) => Neighbourhood.fromJsonCalgary(json))
            .toList();
      case Cities.ottawa:
      default:
        List jsonArray = json.decode(jsonString)['features'];
        return jsonArray
            .map((json) => Neighbourhood.fromJsonOttawa(json))
            .toList();
    }
  }

  static Future<List<Camera>> downloadAll(Cities city) async {
    var cameras = await downloadCameras(city);
    cameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));

    var neighbourhoods = await downloadNeighbourhoods(city);

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

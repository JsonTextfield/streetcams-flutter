import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../entities/Cities.dart';
import '../entities/camera.dart';
import '../entities/neighbourhood.dart';

class DownloadService {
  static Future<List<Camera>> _downloadCameras(Cities city) async {
    Map<Cities, String> urls = {
      Cities.ottawa: 'https://traffic.ottawa.ca/beta/camera_list',
      Cities.toronto:
          'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/a3309088-5fd4-4d34-8297-77c8301840ac/resource/4a568300-c7f8-496d-b150-dff6f5dc6d4f/download/Traffic%20Camera%20List.geojson',
      Cities.montreal:
          'https://ville.montreal.qc.ca/circulation/sites/ville.montreal.qc.ca.circulation/files/cameras-de-circulation.json',
      Cities.calgary: 'https://data.calgary.ca/resource/k7p9-kppz.json',
    };
    Uri url = Uri.parse(urls[city] ?? '');
    return compute(_parseCameraJson, [city, await http.read(url)]);
  }

  static List<Camera> _parseCameraJson(List<dynamic> arguments) {
    Cities city = arguments.first as Cities;
    String jsonString = arguments.last as String;
    List<dynamic> jsonArray = [];
    switch (city) {
      case Cities.toronto:
      case Cities.montreal:
        Map<String, dynamic> jsonObject = json.decode(jsonString);
        jsonArray = jsonObject['features'];
        break;
      case Cities.calgary:
      case Cities.ottawa:
      default:
        jsonArray = json.decode(jsonString);
        break;
    }
    return jsonArray.map((json) => Camera.fromJson(json, city)).toList();
  }

  static Future<List<Neighbourhood>> _downloadNeighbourhoods(
    Cities city,
  ) async {
    Map<Cities, String> urls = {
      Cities.ottawa:
          'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson',
      Cities.toronto:
          'https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/neighbourhoods/resource/1d38e8b7-65a8-4dd0-88b0-ad2ce938126e/download/Neighbourhoods.geojson',
      Cities.montreal:
          'https://donnees.montreal.ca/dataset/f38c91a1-e33f-4475-a112-3b84b1c60c1e/resource/a80e611f-5336-4306-ba2a-fd657f0f00fa/download/quartierreferencehabitation.geojson',
      Cities.calgary: 'https://data.calgary.ca/resource/surr-xmvs.json',
    };
    Uri url = Uri.parse(urls[city] ?? '');
    return compute(_parseNeighbourhoodJson, [city, await http.read(url)]);
  }

  static List<Neighbourhood> _parseNeighbourhoodJson(List<dynamic> arguments) {
    Cities city = arguments.first as Cities;
    String jsonString = arguments.last as String;
    List<dynamic> jsonArray = [];
    switch (city) {
      case Cities.calgary:
        jsonArray = json.decode(jsonString);
        break;
      case Cities.ottawa:
      case Cities.toronto:
      case Cities.montreal:
      default:
        jsonArray = json.decode(jsonString)['features'];
        break;
    }
    return jsonArray.map((json) => Neighbourhood.fromJson(json, city)).toList();
  }

  static Future<(List<Camera>, List<Neighbourhood>)> downloadAll(
      Cities city) async {
    List<Camera> cameras = await _downloadCameras(city);
    cameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));

    List<Neighbourhood> neighbourhoods = await _downloadNeighbourhoods(city);

    for (var camera in cameras) {
      for (var neighbourhood in neighbourhoods) {
        if (neighbourhood.containsCamera(camera)) {
          camera.neighbourhood = city == Cities.montreal
              ? utf8.decode(neighbourhood.name.runes.toList())
              : neighbourhood.name;
        }
      }
    }
    return (cameras, neighbourhoods);
  }
}

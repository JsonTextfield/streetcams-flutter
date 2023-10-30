import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../entities/camera.dart';
import '../entities/city.dart';

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
    String urlString =
        'https://solid-muse-172501.firebaseio.com/cameras.json?orderBy="city"&equalTo="${city.name}"';
    Uri url = Uri.parse(urlString);
    return compute(_parseCameraJson, await http.read(url));
  }

  static List<Camera> _parseCameraJson(String jsonString) {
    Map<String, dynamic> jsonArray = jsonDecode(jsonString);
    return jsonArray.values.map((json) => Camera.fromJson(json)).toList()
      ..sort((a, b) => a.sortableName.compareTo(b.sortableName));
  }
}

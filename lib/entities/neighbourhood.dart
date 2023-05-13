import 'dart:math';

import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'Cities.dart';
import 'camera.dart';
import 'location.dart';

class Neighbourhood extends BilingualObject {
  final List<List<Location>> boundaries;

  const Neighbourhood({
    required this.boundaries,
    required id,
    required nameEn,
    required nameFr,
  }) : super(id: id, nameEn: nameEn, nameFr: nameFr);

  factory Neighbourhood.fromJson(Map<String, dynamic> json, Cities city) {
    List<List<Location>> boundaries = _getBoundaries(json, city);
    switch (city) {
      case Cities.toronto:
        return Neighbourhood(
          boundaries: boundaries,
          id: json['properties']['AREA_ID'],
          nameEn: json['properties']['AREA_NAME'],
          nameFr: json['properties']['AREA_NAME'],
        );
      case Cities.montreal:
        return Neighbourhood(
          boundaries: boundaries,
          id: int.parse(json['properties']['no_qr'], radix: 16),
          nameEn: json['properties']['nom_qr'],
          nameFr: json['properties']['nom_qr'],
        );
      case Cities.calgary:
        return Neighbourhood(
          boundaries: boundaries,
          id: 0,
          nameEn: json['name'],
          nameFr: json['name'],
        );
      case Cities.ottawa:
      default:
        return Neighbourhood(
          boundaries: boundaries,
          id: json['properties']['ONS_ID'],
          nameEn: json['properties']['Name'],
          nameFr: json['properties']['Name_FR'],
        );
    }
  }

  static List<List<Location>> _getBoundaries(
    Map<String, dynamic> json,
    Cities city,
  ) {
    List<dynamic> areas = [];

    switch (city) {
      case Cities.ottawa:
        areas = json['geometry']['coordinates'];
        break;
      case Cities.toronto:
      case Cities.montreal:
        areas = json['geometry']['coordinates'][0];
        break;
      case Cities.calgary:
        areas = json['multipolygon']['coordinates'][0];
        break;
      default:
        break;
    }

    bool hasMultipleParts = areas.length > 1;
    List<List<Location>> boundaries = [];

    for (int i = 0; i < areas.length; i++) {
      var area = (hasMultipleParts ? areas[i][0] : areas[0]) as List<dynamic>;
      List<Location> locationList =
          area.map((jsonArray) => Location.fromJsonArray(jsonArray)).toList();
      boundaries.add(locationList);
    }
    return boundaries;
  }

  //http://en.wikipedia.org/wiki/Point_in_polygon
  //https://stackoverflow.com/questions/26014312/identify-if-point-is-in-the-polygon
  bool containsCamera(Camera camera) {
    var intersectCount = 0;
    for (var vertices in boundaries) {
      for (int j = 0; j < vertices.length - 1; j++) {
        if (onSegment(vertices[j], camera.location, vertices[j + 1])) {
          return true;
        }
        if (rayCastIntersect(camera.location, vertices[j], vertices[j + 1])) {
          intersectCount++;
        }
      }
    }
    return ((intersectCount % 2) == 1); // odd = inside, even = outside
  }

  bool onSegment(Location a, Location location, Location b) {
    return location.lon <= max(a.lon, b.lon) &&
        location.lon >= min(a.lon, b.lon) &&
        location.lat <= max(a.lat, b.lat) &&
        location.lat >= min(a.lat, b.lat);
  }

  bool rayCastIntersect(Location location, Location vertA, Location vertB) {
    var aY = vertA.lat;
    var bY = vertB.lat;
    var aX = vertA.lon;
    var bX = vertB.lon;
    var pY = location.lat;
    var pX = location.lon;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
      // a and b can't both be above or below pt.y, and a or b must be east of pt.x
    }

    var m = (aY - bY) / (aX - bX); // Rise over run
    var bee = (-aX) * m + aY; // y = mx + b
    var x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }
}

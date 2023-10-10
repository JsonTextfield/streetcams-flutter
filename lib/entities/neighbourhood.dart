import 'dart:math';

import 'package:change_case/change_case.dart';
import 'package:flutter/rendering.dart';
import 'package:proj4dart/proj4dart.dart';

import 'bilingual_object.dart';
import 'camera.dart';
import 'city.dart';
import 'location.dart';

class Neighbourhood extends BilingualObject {
  final List<List<Location>> boundaries;

  const Neighbourhood({
    required this.boundaries,
    id = 0,
    nameEn = '',
    nameFr = '',
  }) : super(id: id, nameEn: nameEn, nameFr: nameFr);

  factory Neighbourhood.fromJson(Map<String, dynamic> json, City city) {
    List<List<Location>> boundaries = _getBoundaries(json, city);
    Map<String, dynamic> properties = json['properties'] ?? {};
    switch (city) {
      case City.toronto:
        return Neighbourhood(
          boundaries: boundaries,
          id: properties['AREA_ID'] ?? 0,
          nameEn: properties['AREA_NAME'] ?? '',
        );
      case City.montreal:
        return Neighbourhood(
          boundaries: boundaries,
          id: int.parse(properties['no_qr'] ?? '0', radix: 16),
          nameFr: properties['nom_qr'] ?? '',
        );
      case City.calgary:
        String name = json['name'] ?? '';
        return Neighbourhood(
          boundaries: boundaries,
          nameEn: name.toCapitalCase(),
        );
      case City.surrey:
        debugPrint(boundaries.toString());
        String name = properties['NAME'] ?? '';
        return Neighbourhood(
          boundaries: boundaries,
          nameEn: name.toCapitalCase(),
        );
      case City.ottawa:
      default:
        return Neighbourhood(
          boundaries: boundaries,
          id: properties['ONS_ID'] ?? 0,
          nameEn: properties['Name'] ?? '',
          nameFr: properties['Name_FR'] ?? '',
        );
    }
  }

  static List<List<Location>> _getBoundaries(
    Map<String, dynamic> json,
    City city,
  ) {
    List<dynamic> areas = [];
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    List<dynamic> geometryCoordinates = geometry['coordinates'] ?? [];
    Map<String, dynamic> multiPolygon = json['multipolygon'] ?? {};
    List<dynamic> multiPolygonCoordinates = multiPolygon['coordinates'] ?? [];

    switch (city) {
      case City.ottawa:
      case City.surrey:
        areas = geometryCoordinates;
        break;
      case City.toronto:
      case City.montreal:
        areas = geometryCoordinates[0] ?? [];
        break;
      case City.calgary:
        areas = multiPolygonCoordinates[0] ?? [];
        break;
      default:
        break;
    }

    bool hasMultipleParts = areas.length > 1;
    List<List<Location>> boundaries = [];

    for (int i = 0; i < areas.length; i++) {
      var area = (hasMultipleParts ? areas[i][0] : areas[0]) as List<dynamic>;
      List<Location> locationList = area.map((jsonArray) {
        if (city == City.surrey) {
          String def =
              '+proj=utm +zone=10 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs';
          Projection projection = Projection.add('EPSG:26910', def);
          Point point = projection.transform(
            Projection.get('EPSG:4326')!,
            Point.fromArray([jsonArray[0] as double, jsonArray[1] as double]),
          );
          return Location.fromJsonArray(point.toArray());
        }
        return Location.fromJsonArray(jsonArray);
      }).toList();
      boundaries.add(locationList);
    }
    return boundaries;
  }

  //http://en.wikipedia.org/wiki/Point_in_polygon
  //https://stackoverflow.com/questions/26014312/identify-if-point-is-in-the-polygon
  bool containsCamera(Camera camera) {
    int intersectCount = 0;
    for (List<Location> points in boundaries) {
      for (int j = 0; j < points.length - 1; j++) {
        // if the point is on the border of a neighbourhood, just return true
        if (onSegment(points[j], camera.location, points[j + 1])) {
          return true;
        }
        if (rayCastIntersect(camera.location, points[j], points[j + 1])) {
          intersectCount++;
        }
      }
    }
    // odd = inside, even = outside
    return intersectCount.isOdd;
  }

  /// Checks if a [Location] is on a line between two [Location]s
  static bool onSegment(Location a, Location loc, Location b) {
    // double division by 0 results in infinity
    double rise = b.lat - a.lat;
    double run = b.lon - a.lon;
    double slope = rise / run;

    double rise2 = b.lat - loc.lat;
    double run2 = b.lon - loc.lon;
    double slope2 = rise2 / run2;

    return loc.lon <= max(a.lon, b.lon) &&
        loc.lon >= min(a.lon, b.lon) &&
        loc.lat <= max(a.lat, b.lat) &&
        loc.lat >= min(a.lat, b.lat) &&
        slope2.abs() == slope.abs();
  }

  static bool rayCastIntersect(Location loc, Location a, Location b) {
    double aX = a.lon;
    double aY = a.lat;
    double bX = b.lon;
    double bY = b.lat;
    double locX = loc.lon;
    double locY = loc.lat;

    if ((aY > locY && bY > locY) ||
        (aY < locY && bY < locY) ||
        (aX < locX && bX < locX)) {
      // a and b can't both be above or below pt.y, and a or b must be east of pt.x
      return false;
    }

    // vertical line
    if (aX == bX) {
      return aX >= locX;
    }

    double rise = aY - bY;
    double run = aX - bX;
    double slope = rise / run;

    double c = -slope * aX + aY; // c = -mx + y
    double x = (locY - c) / slope;

    return x >= locX;
  }
}

import 'dart:math';

import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'Cities.dart';
import 'camera.dart';
import 'location.dart';

class Neighbourhood extends BilingualObject {
  final List<List<Location>> boundaries;

  const Neighbourhood({
    required this.boundaries,
    id = 0,
    nameEn = '',
    nameFr = '',
  }) : super(id: id, nameEn: nameEn, nameFr: nameFr);

  factory Neighbourhood.fromJson(Map<String, dynamic> json, Cities city) {
    List<List<Location>> boundaries = _getBoundaries(json, city);
    Map<String, dynamic> properties = json['properties'] ?? {};
    switch (city) {
      case Cities.toronto:
        return Neighbourhood(
          boundaries: boundaries,
          id: properties['AREA_ID'] ?? 0,
          nameEn: properties['AREA_NAME'] ?? '',
        );
      case Cities.montreal:
        return Neighbourhood(
          boundaries: boundaries,
          id: int.parse(properties['no_qr'] ?? '0', radix: 16),
          nameFr: properties['nom_qr'] ?? '',
        );
      case Cities.calgary:
        return Neighbourhood(
          boundaries: boundaries,
          nameEn: json['name'] ?? '',
        );
      case Cities.ottawa:
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
    Cities city,
  ) {
    List<dynamic> areas = [];
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    List<dynamic> geometryCoordinates = geometry['coordinates'] ?? [];
    Map<String, dynamic> multiPolygon = json['multipolygon'] ?? {};
    List<dynamic> multiPolygonCoordinates = multiPolygon['coordinates'] ?? [];

    switch (city) {
      case Cities.ottawa:
        areas = geometryCoordinates;
        break;
      case Cities.toronto:
      case Cities.montreal:
        areas = geometryCoordinates[0] ?? [];
        break;
      case Cities.calgary:
        areas = multiPolygonCoordinates[0] ?? [];
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
        slope2 == slope;
  }

  static bool rayCastIntersect(Location loc, Location a, Location b) {
    double aX = a.lon;
    double aY = a.lat;
    double bX = b.lon;
    double bY = b.lat;
    double locX = loc.lon;
    double locY = loc.lat;

    if (aX == bX) {
      return aX >= locX;
    }

    if (aY == bY) {
      return aY >= locY;
    }

    if ((aY > locY && bY > locY) ||
        (aY < locY && bY < locY) ||
        (aX < locX && bX < locX)) {
      // a and b can't both be above or below pt.y, and a or b must be east of pt.x
      return false;
    }

    double rise = aY - bY;
    double run = aX - bX;
    double slope = rise / run;

    double c = -slope * aX + aY; // c = -mx + y
    double x = (locY - c) / slope;

    return x >= locX;
  }
}

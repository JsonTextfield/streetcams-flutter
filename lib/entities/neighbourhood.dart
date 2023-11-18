import 'dart:math';

import 'package:change_case/change_case.dart';
import 'package:proj4dart/proj4dart.dart';

import 'bilingual_object.dart';
import 'camera.dart';
import 'city.dart';
import 'location.dart';

class Neighbourhood extends BilingualObject {
  final List<List<Location>> boundaries;

  const Neighbourhood({
    required this.boundaries,
    super.nameEn = '',
    super.nameFr = '',
  });

  factory Neighbourhood.fromJson(Map<String, dynamic> json, City city) {
    Map<String, dynamic> properties = json['properties'] ?? {};
    switch (city) {
      case City.toronto:
        return Neighbourhood(
          boundaries: _createBoundaries(city, json['geometry'] ?? {}),
          //id: properties['AREA_ID'] ?? 0,
          nameEn: properties['AREA_NAME'] ?? '',
        );
      case City.montreal:
        return Neighbourhood(
          boundaries: _createBoundaries(city, json['geometry'] ?? {}),
          //id: int.parse(properties['no_qr'] ?? '0', radix: 16),
          nameFr: properties['nom_qr'] ?? '',
        );
      case City.calgary:
        String name = json['name'] ?? '';
        return Neighbourhood(
          boundaries: _createBoundaries(city, json['multipolygon'] ?? {}),
          nameEn: name.toCapitalCase(),
        );
      case City.surrey:
        String name = properties['NAME'] ?? '';
        return Neighbourhood(
          boundaries: _createBoundaries(city, json['geometry'] ?? {}),
          nameEn: name.toCapitalCase(),
        );
      case City.ottawa:
      default:
        return Neighbourhood(
          boundaries: _createBoundaries(city, json['geometry'] ?? {}),
          //id: properties['ONS_ID'] ?? 0,
          nameEn: properties['Name'] ?? '',
          nameFr: properties['Name_FR'] ?? '',
        );
    }
  }

  static List<List<Location>> _createBoundaries(
    City city,
    Map<String, dynamic> geometry,
  ) {
    List<List<Location>> boundaries = [];
    List<dynamic> neighbourhoodZones = [];

    if (geometry['type'].toString().toLowerCase() == 'polygon') {
      neighbourhoodZones.add(geometry['coordinates']);
    } else {
      neighbourhoodZones = geometry['coordinates'];
    }

    for (int item = 0; item < neighbourhoodZones.length; item++) {
      List<dynamic> points = neighbourhoodZones[item][0];
      List<Location> list = [];
      for (int i = 0; i < points.length; i++) {
        if (city == City.surrey) {
          Projection projection = Projection.add(
            'EPSG:26910',
            '+proj=utm +zone=10 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs',
          );
          Point point = projection.transform(
            Projection.get('EPSG:4326')!,
            Point.fromArray(List<double>.from(points[i])),
          );
          list.add(Location.fromJsonArray(point.toArray()));
        } //
        else {
          list.add(Location.fromJsonArray(List<double>.from(points[i])));
        }
      }
      boundaries.add(list);
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

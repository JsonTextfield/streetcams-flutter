import 'package:geolocator/geolocator.dart';

class Location {
  final double lat;
  final double lon;

  const Location({
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['latitude'],
      lon: json['longitude'],
    );
  }

  factory Location.fromJsonArray(List<dynamic> json) {
    return Location(
      lat: json[1],
      lon: json[0],
    );
  }

  double distanceTo(Location other) {
    return distanceBetween(this, other);
  }

  static double distanceBetween(Location a, Location b) {
    return Geolocator.distanceBetween(a.lat, a.lon, b.lat, b.lon);
  }
}

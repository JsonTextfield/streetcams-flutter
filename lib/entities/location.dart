import 'package:geolocator/geolocator.dart';

class Location {
  final double lat;
  final double lon;

  const Location({
    required this.lat,
    required this.lon,
  });

  factory Location.createFromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['latitude'],
      lon: json['longitude'],
    );
  }

  factory Location.createFromJsonArray(List<dynamic> json) {
    return Location(
      lat: json[0],
      lon: json[1],
    );
  }

  double distanceTo(Location other) {
    return distanceBetween(this, other);
  }

  static double distanceBetween(Location a, Location b) {
    return Geolocator.distanceBetween(a.lat, a.lon, b.lat, b.lon);
  }
}

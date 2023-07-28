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
      lat: json['latitude'] ?? 0.0,
      lon: json['longitude'] ?? 0.0,
    );
  }

  factory Location.fromJsonArray(List<dynamic> json) {
    return Location(
      lat: json[1],
      lon: json[0],
    );
  }

  factory Location.fromPosition(Position position) {
    return Location(
      lat: position.latitude,
      lon: position.longitude,
    );
  }

  double distanceTo(Location other) {
    return distanceBetween(this, other);
  }

  static double distanceBetween(Location a, Location b) {
    return Geolocator.distanceBetween(a.lat, a.lon, b.lat, b.lon);
  }

  @override
  String toString() => '[$lat, $lon]';
}

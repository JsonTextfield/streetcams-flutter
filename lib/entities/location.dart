import 'package:geolocator/geolocator.dart';

class Location {
  final double lat;
  final double lon;

  const Location({
    required this.lat,
    required this.lon,
  });

  factory Location.fromMap(Map<String, dynamic> json,
      {bool useUppercase = false}) {
    return Location(
      lat: json[useUppercase ? 'Latitude' : 'latitude'] ?? 0.0,
      lon: json[useUppercase ? 'Longitude' : 'longitude'] ?? 0.0,
    );
  }

  factory Location.fromList(List<double> json) {
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

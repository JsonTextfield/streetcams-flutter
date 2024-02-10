import 'package:geolocator/geolocator.dart';

final class LatLon {
  final double lat;
  final double lon;

  const LatLon({
    required this.lat,
    required this.lon,
  });

  factory LatLon.fromMap(Map<String, dynamic> json) {
    return LatLon(
      lat: json['lat'] ?? 0.0,
      lon: json['lon'] ?? 0.0,
    );
  }

  factory LatLon.fromPosition(Position position) {
    return LatLon(
      lat: position.latitude,
      lon: position.longitude,
    );
  }

  double distanceTo(LatLon other) {
    return distanceBetween(this, other);
  }

  static double distanceBetween(LatLon a, LatLon b) {
    return Geolocator.distanceBetween(a.lat, a.lon, b.lat, b.lon);
  }

  @override
  String toString() => '[$lat, $lon]';
}

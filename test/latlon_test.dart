import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:streetcams_flutter/entities/latlon.dart';

void main() {
  test('test LatLon creation from json', () {
    var latLon = LatLon.fromMap({'lat': 13.37, 'lon': 19.95});
    expect(latLon.lat, 13.37);
    expect(latLon.lon, 19.95);
  });
  test('test LatLon creation from position', () {
    var position = Position.fromMap({'latitude': 13.37, 'longitude': 19.95});
    var latLon = LatLon.fromPosition(position);
    expect(latLon.lat, 13.37);
    expect(latLon.lon, 19.95);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:streetcams_flutter/entities/location.dart';

void main() {
  test('test location creation from json', () {
    var location = Location.fromJson({'lat': 13.37, 'lon': 19.95});
    expect(location.lat, 13.37);
    expect(location.lon, 19.95);
  });
  test('test location creation from json array', () {
    var location = Location.fromJsonArray([19.95, 13.37]);
    expect(location.lat, 13.37);
    expect(location.lon, 19.95);
  });
  test('test location creation from position', () {
    var position = Position.fromMap({'latitude': 13.37, 'longitude': 19.95});
    var location = Location.fromPosition(position);
    expect(location.lat, 13.37);
    expect(location.lon, 19.95);
  });
}

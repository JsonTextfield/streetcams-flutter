import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/entities/location.dart';
import 'package:streetcams_flutter/entities/neighbourhood.dart';

void main() {
  test('test point on line segment', () {
    var location1 = const Location(lat: 0.0, lon: -5.0);
    var location2 = const Location(lat: 0.0, lon: 15);
    var location3 = const Location(lat: 0.0, lon: 10.0);

    expect(Neighbourhood.onSegment(location1, location2, location3), false);

    location2 = const Location(lat: 0.0, lon: 5.4321);

    expect(Neighbourhood.onSegment(location1, location2, location3), true);

    location1 = const Location(lat: -20.0, lon: -5.0);
    location2 = const Location(lat: 4.0, lon: 1.0);
    location3 = const Location(lat: 50.0, lon: 12.5);

    expect(Neighbourhood.onSegment(location1, location2, location3), true);

    location3 = const Location(lat: 50.0, lon: 12.5000001);

    expect(Neighbourhood.onSegment(location1, location2, location3), false);
  });

  test('test point on vertical line segment', () {
    var location1 = const Location(lat: 15.0, lon: 0.0);
    var location2 = const Location(lat: 0.0, lon: 0.0);
    var location3 = const Location(lat: -10.0, lon: 0.0);
    expect(Neighbourhood.onSegment(location1, location2, location3), true);
  });

  test('test containsCamera', () {
    var neighbourhood = Neighbourhood.fromJson(
      {
        'geometry': {
          'type': 'polygon',
          'coordinates': [
            [
              [-78.0, 45.0],
              [-75.0, 45.0],
              [-75.0, 46.0],
              [-78.0, 45.0],
            ],
          ],
        },
      },
      City.ottawa,
    );
    var camera = Camera.fromJson(
      {
        'longitude': -75.696969,
        'latitude': 45.454545,
      },
      City.ottawa,
    );
    expect(neighbourhood.containsCamera(camera), true);

    var camera2 = Camera.fromJson(
      {
        'longitude': -75.0,
        'latitude': 23.999,
      },
      City.ottawa,
    );
    expect(neighbourhood.containsCamera(camera2), false);
  });
}

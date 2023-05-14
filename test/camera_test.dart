import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/entities/Cities.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/location.dart';

void main() {
  test('test equality', () {
    int num = 1337;
    int id = 9999;
    String name = 'Camera';
    String nameFr = 'CameraFr';
    Location location = const Location(lat: 45.454545, lon: -75.696969);
    Cities city = Cities.ottawa;

    var camera1 = Camera(
      city: city,
      num: num,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
    );
    var camera2 = Camera(
      city: city,
      num: num,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
    );

    expect(camera1, camera2);
  });

  test('test equality with non-equatable fields', () {
    int num = 1337;
    int id = 9999;
    String name = 'Camera';
    String nameFr = 'CameraFr';
    Location location = const Location(lat: 45.454545, lon: -75.696969);
    Cities city = Cities.ottawa;

    var camera1 = Camera(
      city: city,
      num: num,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
      url: 'test.url',
    )
      ..neighbourhood = 'Riverdale'
      ..isVisible = true
      ..isFavourite = false;

    var camera2 = Camera(
      city: city,
      num: num,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
      url: 'url.test',
    )
      ..neighbourhood = 'Downtown'
      ..isVisible = false
      ..isFavourite = true;

    expect(camera1, camera2);
  });

  test('camera creation city from json', () {
    var camera = Camera.fromJson({}, Cities.ottawa);
    expect(camera.city, Cities.ottawa);

    camera = Camera.fromJson({}, Cities.toronto);
    expect(camera.city, Cities.toronto);

    camera = Camera.fromJson({}, Cities.montreal);
    expect(camera.city, Cities.montreal);

    camera = Camera.fromJson({}, Cities.calgary);
    expect(camera.city, Cities.calgary);
  });
}

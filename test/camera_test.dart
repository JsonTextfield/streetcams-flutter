import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/entities/latlon.dart';

void main() {
  test('test equality', () {
    String nameEn = 'CameraEn';
    String nameFr = 'CameraFr';
    LatLon location = const LatLon(lat: 45.454545, lon: -75.696969);
    City city = City.ottawa;

    var camera1 = Camera(
        city: city,
        location: location,
        name: BilingualObject(en: nameEn, fr: nameFr));
    var camera2 = Camera(
        city: city,
        location: location,
        name: BilingualObject(en: nameEn, fr: nameFr));

    expect(camera1, camera2);
  });

  test('test equality with non-equatable fields', () {
    String nameEn = 'CameraEn';
    String nameFr = 'CameraFr';
    LatLon location = const LatLon(lat: 45.454545, lon: -75.696969);
    City city = City.ottawa;

    var camera1 = Camera(
      city: city,
      location: location,
      name: BilingualObject(en: nameEn, fr: nameFr),
      neighbourhood: const BilingualObject(en: 'Riverdale'),
      url: 'test.url',
    )
      ..isVisible = true
      ..isFavourite = false;

    var camera2 = Camera(
      city: city,
      location: location,
      name: BilingualObject(en: nameEn, fr: nameFr),
      neighbourhood: const BilingualObject(en: 'Downtown'),
      url: 'url.test',
    )
      ..isVisible = false
      ..isFavourite = true;

    expect(camera1, camera2);
  });

  test('camera creation city from json', () {
    var camera = Camera.fromJson(<String, dynamic>{'city': 'ottawa'});
    expect(camera.city, City.ottawa);

    camera = Camera.fromJson(<String, dynamic>{'city': 'toronto'});
    expect(camera.city, City.toronto);
  });
}

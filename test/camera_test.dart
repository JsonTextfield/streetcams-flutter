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

    var camera1 = Camera(
      city: Cities.ottawa,
      num: num,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
    );
    var camera2 = Camera(
      city: Cities.ottawa,
      num: num,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
    );

    expect(camera1, camera2);
  });

  test('test equality different name', () {
    int num = 1337;
    int id = 9999;
    Location location = const Location(lat: 45.454545, lon: -75.696969);

    var camera1 = Camera(
      city: Cities.ottawa,
      num: num,
      location: location,
      id: id,
      nameEn: 'Camera1',
      nameFr: 'Camera1F',
    );
    var camera2 = Camera(
      city: Cities.ottawa,
      num: num,
      location: location,
      id: id,
      nameEn: 'Camera2',
      nameFr: 'Camera2FR',
    );

    expect(camera1, camera2);
  });

  test('test inequality different num', () {
    int id = 9999;
    String name = 'Camera';
    String nameFr = 'CameraFr';
    Location location = const Location(lat: 45.454545, lon: -75.696969);

    var camera1 = Camera(
      city: Cities.ottawa,
      num: 1337,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
    );
    var camera2 = Camera(
      city: Cities.ottawa,
      num: 8347,
      location: location,
      id: id,
      nameEn: name,
      nameFr: nameFr,
    );

    expect(camera1 == camera2, false);
  });

  test('test inequality different id', () {
    int num = 1337;
    String name = 'Camera';
    String nameFr = 'CameraFr';
    Location location = const Location(lat: 45.454545, lon: -75.696969);

    var camera1 = Camera(
      city: Cities.ottawa,
      num: num,
      location: location,
      id: 9999,
      nameEn: name,
      nameFr: nameFr,
    );
    var camera2 = Camera(
      city: Cities.ottawa,
      num: num,
      location: location,
      id: 1111,
      nameEn: name,
      nameFr: nameFr,
    );

    expect(camera1 == camera2, false);
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

  test('test toTitleCase extension', () {
    expect('TEST. THIS. TITLE.'.toTitleCase(), 'Test. This. Title.');
    expect('test. this. title.'.toTitleCase(), 'Test. This. Title.');
    expect('tEsT. tHiS. tItLe.'.toTitleCase(), 'Test. This. Title.');
  });
}

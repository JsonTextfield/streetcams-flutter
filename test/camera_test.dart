import 'package:flutter_test/flutter_test.dart';
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
      num: num,
      location: location,
      id: id,
      type: '',
      nameEn: name,
      nameFr: nameFr,
    );
    var camera2 = Camera(
      num: num,
      location: location,
      id: id,
      type: '',
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
      num: num,
      location: location,
      id: id,
      type: '',
      nameEn: 'Camera1',
      nameFr: 'Camera1F',
    );
    var camera2 = Camera(
      num: num,
      location: location,
      id: id,
      type: '',
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
      num: 1337,
      location: location,
      id: id,
      type: '',
      nameEn: name,
      nameFr: nameFr,
    );
    var camera2 = Camera(
      num: 8347,
      location: location,
      id: id,
      type: '',
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
      num: num,
      location: location,
      id: 9999,
      type: '',
      nameEn: name,
      nameFr: nameFr,
    );
    var camera2 = Camera(
      num: num,
      location: location,
      id: 1111,
      type: '',
      nameEn: name,
      nameFr: nameFr,
    );

    expect(camera1 == camera2, false);
  });
}
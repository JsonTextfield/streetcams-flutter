import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';

void main() {
  test('camera creation city from json', () {
    var camera = Camera.fromJson(<String, dynamic>{'city': 'ottawa'});
    expect(camera.city, City.ottawa);

    camera = Camera.fromJson(<String, dynamic>{'city': 'toronto'});
    expect(camera.city, City.toronto);
  });
}

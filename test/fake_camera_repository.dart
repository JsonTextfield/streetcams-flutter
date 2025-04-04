import 'package:streetcams_flutter/data/camera_repository.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/entities/latlon.dart';

class FakeCameraRepository implements ICameraRepository {
  @override
  Future<List<Camera>> getCameras(City city) async {
    return List.generate(5, (i) {
      return Camera(
        id: '$i',
        location: const LatLon(lat: 43.0, lon: -79.0),
        city: city,
      );
    });
  }
}

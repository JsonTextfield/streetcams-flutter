import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/services/download_service.dart';

abstract class ICameraRepository {
  Future<List<Camera>> getCameras(City city);
}

class CameraRepository implements ICameraRepository {
  @override
  Future<List<Camera>> getCameras(City city) {
    return DownloadService.getCameras(city);
  }
}

import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';

import 'camera_data_source.dart';

abstract class ICameraRepository {
  Future<List<Camera>> getCameras(City city);
}

class CameraRepository implements ICameraRepository {
  final ICameraDataSource _cameraDataSource;

  CameraRepository(this._cameraDataSource);

  @override
  Future<List<Camera>> getCameras(City city) async {
    return await _cameraDataSource.getAllCameras(city);
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:streetcams_flutter/pages/home_page.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/services/location_service.dart';

import '../entities/camera.dart';
import '../entities/location.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  List<Camera> allCameras = [];

  CameraBloc() : super(const CameraState()) {
    on<CameraLoaded>((event, emit) async {
      allCameras = await DownloadService.downloadAll();
      return emit(CameraState(
        allCameras: allCameras,
        status: CameraStatus.success,
      ));
    });
    on<SortCameras>((event, emit) async {
      switch (event.method) {
        case CameraSortingMethod.distance:
          var position = await LocationService.getCurrentLocation();
          var location = Location.fromPosition(position);
          sortByDistance(location);
          break;
        case CameraSortingMethod.neighbourhood:
          sortByNeighbourhood();
          break;
        case CameraSortingMethod.name:
        default:
          sortByName();
          break;
      }
      return emit(CameraState(
        allCameras: allCameras,
        status: CameraStatus.success,
        sortingMethod: event.method,
      ));
    });
  }

  void sortByName() {
    allCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
  }

  void sortByDistance(Location location) {
    allCameras.sort((a, b) {
      int result = location
          .distanceTo(a.location)
          .compareTo(location.distanceTo(b.location));
      if (result == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
  }

  void sortByNeighbourhood() {
    allCameras.sort((a, b) {
      int result = a.neighbourhood.compareTo(b.neighbourhood);
      if (a.neighbourhood.compareTo(b.neighbourhood) == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
  }
}

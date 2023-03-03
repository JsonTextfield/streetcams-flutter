import 'package:flutter/widgets.dart';

import 'blocs/camera_bloc.dart';
import 'entities/camera.dart';
import 'entities/location.dart';


class CameraModel extends ChangeNotifier {
  final List<Camera> _allCameras = [];
  final List<Camera> _selectedCameras = [];
  List<Camera> displayedCameras = [];
  bool isFiltered = false;
  CameraSortingMethod sortingMethod = CameraSortingMethod.name;

  void sortByName() {
    displayedCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
    sortingMethod = CameraSortingMethod.name;
    notifyListeners();
  }

  void sortByDistance(Location location) {
    displayedCameras.sort((a, b) {
      int result = location
          .distanceTo(a.location)
          .compareTo(location.distanceTo(b.location));
      if (result == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
    sortingMethod = CameraSortingMethod.distance;
    notifyListeners();
  }

  void sortByNeighbourhood() {
    displayedCameras.sort((a, b) {
      int result = a.neighbourhood.compareTo(b.neighbourhood);
      if (a.neighbourhood.compareTo(b.neighbourhood) == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
    sortingMethod = CameraSortingMethod.neighbourhood;
    notifyListeners();
  }

  void _selectCamera(Camera camera) {
    if (_selectedCameras.contains(camera)) {
      _selectedCameras.remove(camera);
    } else {
      _selectedCameras.add(camera);
    }
    notifyListeners();
  }

  void clearSelectedCameras() {
    _selectedCameras.clear();
    notifyListeners();
  }

  void filterDisplayedCameras(bool Function(Camera) predicate) {
    displayedCameras = displayedCameras.where(predicate).toList();
    isFiltered = true;
    notifyListeners();
  }

  void resetDisplayedCameras() {
    displayedCameras =
        _allCameras.where((camera) => camera.isVisible).toList();
    notifyListeners();
  }

  void favouriteSelectedCameras() {
    var allFavourite = _selectedCameras.every((camera) => camera.isFavourite);
    for (var camera in _selectedCameras) {
      camera.isFavourite = !allFavourite;
    }
    notifyListeners();
  }

  void hideSelectedCameras() {
    var allHidden = _selectedCameras.every((camera) => camera.isVisible);
    for (var camera in _selectedCameras) {
      camera.isVisible = !allHidden;
    }
    notifyListeners();
  }
}

import 'entities/camera.dart';
import 'entities/location.dart';

enum CameraSortingEnum { name, distance, neighbourhood }

class CameraModel {
  final List<Camera> _allCameras;
  final List<Camera> _selectedCameras = [];
  List<Camera> _displayedCameras = [];
  bool isFiltered = false;
  CameraSortingEnum sortingMethod = CameraSortingEnum.name;

  CameraModel(this._allCameras) {
    resetDisplayedCameras();
  }

  void sortByName() {
    _displayedCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
    sortingMethod = CameraSortingEnum.name;
  }

  void sortByDistance(Location location) {
    _displayedCameras.sort((a, b) {
      int result = location
          .distanceTo(a.location)
          .compareTo(location.distanceTo(b.location));
      if (result == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
    sortingMethod = CameraSortingEnum.distance;
  }

  void sortByNeighbourhood() {
    _displayedCameras.sort((a, b) {
      int result = a.neighbourhood.compareTo(b.neighbourhood);
      if (a.neighbourhood.compareTo(b.neighbourhood) == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
    sortingMethod = CameraSortingEnum.neighbourhood;
  }

  bool _selectCamera(Camera camera) {
    if (_selectedCameras.contains(camera)) {
      _selectedCameras.remove(camera);
      return false;
    }
    _selectedCameras.add(camera);
    return true;
  }

  void clearSelectedCameras() {
    _selectedCameras.clear();
  }

  CameraModel filterDisplayedCameras(bool Function(Camera) predicate) {
    _displayedCameras = _displayedCameras.where(predicate).toList();
    isFiltered = true;
    return this;
  }

  void resetDisplayedCameras() {
    _displayedCameras =
        _allCameras.where((camera) => !camera.isHidden).toList();
  }

  void favouriteSelectedCameras() {
    var allFavourite = _selectedCameras.every((camera) => camera.isFavourite);
    for (var camera in _selectedCameras) {
      camera.isFavourite = !allFavourite;
    }
  }

  void hideSelectedCameras() {
    var allHidden = _selectedCameras.every((camera) => camera.isHidden);
    for (var camera in _selectedCameras) {
      camera.isHidden = !allHidden;
    }
  }
}

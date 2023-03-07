import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/services/location_service.dart';

import '../entities/camera.dart';
import '../entities/location.dart';
import '../entities/neighbourhood.dart';

part 'camera_event.dart';
part 'camera_state.dart';

const int _maxCameras = 8;

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  SharedPreferences? _prefs;
  List<Camera> allCameras = [];
  List<Neighbourhood> neighbourhoods = [];

  CameraBloc() : super(const CameraState()) {
    on<CameraLoaded>((event, emit) async {
      _prefs = await SharedPreferences.getInstance();
      allCameras = await DownloadService.downloadAll();
      neighbourhoods = await DownloadService.downloadNeighbourhoods();
      readSharedPrefs();
      return emit(CameraState(
        displayedCameras: allCameras.where((cam) => cam.isVisible).toList(),
        neighbourhoods: neighbourhoods,
        allCameras: allCameras,
        status: CameraStatus.success,
      ));
    });

    on<ReloadCameras>((event, emit) async {
      readSharedPrefs();
      return emit(CameraState(
        showList: event.showList,
        displayedCameras: allCameras.where((cam) => cam.isVisible).toList(),
        neighbourhoods: neighbourhoods,
        allCameras: allCameras,
        status: CameraStatus.success,
      ));
    });

    on<SortCameras>((event, emit) async {
      switch (event.method) {
        case SortMode.distance:
          var position = await LocationService.getCurrentLocation();
          var location = Location.fromPosition(position);
          sortByDistance(location);
          break;
        case SortMode.neighbourhood:
          sortByNeighbourhood();
          break;
        case SortMode.name:
        default:
          sortByName();
          break;
      }
      return emit(CameraState(
        allCameras: allCameras,
        displayedCameras: state.displayedCameras,
        status: CameraStatus.success,
        sortingMethod: event.method,
      ));
    });

    on<SearchCameras>((event, emit) async {
      List<Camera> result = state.visibleCameras.toList();
      switch (event.searchMode) {
        case SearchMode.camera:
          result = searchByCamera(event.query);
          break;
        case SearchMode.neighbourhood:
          result = searchByNeighbourhood(event.query);
          break;
        case SearchMode.none:
        default:
          break;
      }
      return emit(CameraState(
        allCameras: allCameras,
        neighbourhoods: neighbourhoods,
        displayedCameras: result,
        status: CameraStatus.success,
        searchMode: event.searchMode,
      ));
    });

    on<FilterCamera>((event, emit) async {
      List<Camera> displayedCameras = allCameras.toList();
      switch (event.filterMode) {
        case FilterMode.favourite:
          displayedCameras =
              allCameras.where((camera) => camera.isFavourite).toList();
          break;
        case FilterMode.visible:
          displayedCameras =
              allCameras.where((camera) => camera.isVisible).toList();
          break;
        case FilterMode.hidden:
          displayedCameras =
              allCameras.where((camera) => !camera.isVisible).toList();
          break;
        default:
          break;
      }
      return emit(CameraState(
        allCameras: allCameras,
        status: CameraStatus.success,
        filterMode: event.filterMode,
        displayedCameras: displayedCameras,
      ));
    });

    on<SelectCamera>((event, emit) async {
      var selectedCameras = state.selectedCameras.toList();
      if (selectedCameras.contains(event.camera)) {
        selectedCameras.remove(event.camera);
      } else {
        selectedCameras.add(event.camera);
      }
      return emit(CameraState(
        status: CameraStatus.success,
        allCameras: allCameras,
        displayedCameras: state.displayedCameras,
        selectedCameras: selectedCameras,
      ));
    });

    on<SelectAll>((event, emit) async {
      return emit(CameraState(
        displayedCameras: state.displayedCameras,
        allCameras: allCameras,
        selectedCameras: state.displayedCameras,
        status: CameraStatus.success,
      ));
    });

    on<ClearSelection>((event, emit) async {
      return emit(CameraState(
        displayedCameras: state.displayedCameras,
        allCameras: allCameras,
        selectedCameras: const [],
        status: CameraStatus.success,
      ));
    });
  }

  List<Camera> filterDisplayedCameras(bool Function(Camera) predicate) {
    return allCameras.where(predicate).toList();
  }

  void sortByName() {
    state.displayedCameras
        .sort((a, b) => a.sortableName.compareTo(b.sortableName));
  }

  void sortByDistance(Location location) {
    state.displayedCameras.sort((a, b) {
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
    state.displayedCameras.sort((a, b) {
      int result = a.neighbourhood.compareTo(b.neighbourhood);
      if (a.neighbourhood.compareTo(b.neighbourhood) == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
  }

  List<Camera> searchByCamera(String query) {
    List<Camera> result = allCameras.where((cam) => cam.isVisible).toList();
    String q = query.toLowerCase();
    if (q.startsWith('f:')) {
      q = q.substring(2).trim();
      result.removeWhere((camera) => !camera.isFavourite);
    } else if (q.startsWith('h:')) {
      q = q.substring(2).trim();
      result.removeWhere((camera) => camera.isVisible);
    }
    result.removeWhere((camera) => !camera.name.toLowerCase().contains(q));
    return result;
  }

  List<Camera> searchByNeighbourhood(String query) {
    return allCameras.where((cam) {
      return cam.isVisible &&
          cam.neighbourhood.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void favouriteSelectedCameras() {
    var allFave = state.selectedCameras.every((camera) => camera.isFavourite);
    for (var element in state.selectedCameras) {
      element.isFavourite = !allFave;
    }
    writeSharedPrefs();
  }

  void hideSelectedCameras() {
    var allHidden = state.selectedCameras.every((camera) => !camera.isVisible);
    for (var camera in state.selectedCameras) {
      camera.isVisible = !allHidden;
    }
    writeSharedPrefs();
  }

  void favouriteCamera(Camera camera) {
    camera.isFavourite = !camera.isFavourite;
    writeSharedPrefs();
    add(ReloadCameras());
  }

  void hideCamera(Camera camera) {
    camera.isVisible = !camera.isVisible;
    writeSharedPrefs();
    add(ReloadCameras());
  }

  void writeSharedPrefs() {
    for (var camera in allCameras) {
      _prefs?.setBool('${camera.sortableName}.isFavourite', camera.isFavourite);
      _prefs?.setBool('${camera.sortableName}.isVisible', camera.isVisible);
    }
  }

  void readSharedPrefs() {
    for (var c in allCameras) {
      c.isFavourite = _prefs?.getBool('${c.sortableName}.isFavourite') ?? false;
      c.isVisible = _prefs?.getBool('${c.sortableName}.isVisible') ?? true;
    }
  }
}

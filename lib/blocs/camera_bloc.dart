import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/services/location_service.dart';

import '../entities/Cities.dart';
import '../entities/camera.dart';
import '../entities/location.dart';
import '../entities/neighbourhood.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  SharedPreferences? _prefs;

  CameraBloc() : super(const CameraState()) {
    on<CameraLoading>((event, emit) async {
      _prefs ??= await SharedPreferences.getInstance();
      return emit(state.copyWith(
        status: CameraStatus.initial,
        searchMode: SearchMode.none,
        filterMode: FilterMode.visible,
      ));
    });

    on<CameraLoaded>((event, emit) async {
      _prefs ??= await SharedPreferences.getInstance();
      Cities city = Cities.ottawa;
      if (_prefs?.getString('city') != null && _prefs!.getString('city')!.isNotEmpty) {
        String str = _prefs!.getString('city')!;
        city = Cities.values.firstWhere((e) => describeEnum(e) == str);
      }
      List<dynamic> allData = await DownloadService.downloadAll(city);
      List<Camera> allCameras = allData.first;
      for (var c in allCameras) {
        c.isFavourite =
            _prefs!.getBool('${c.sortableName}${c.id}.isFavourite') ?? false;
        c.isVisible =
            _prefs!.getBool('${c.sortableName}${c.id}.isVisible') ?? true;
      }
      return emit(state.copyWith(
        displayedCameras: allCameras.where((cam) => cam.isVisible).toList(),
        neighbourhoods: allData.last,
        allCameras: allCameras,
        status: CameraStatus.success,
        city: city,
        sortingMethod: SortingMethod.name,
        filterMode: FilterMode.visible,
        searchMode: SearchMode.none,
      ));
    });

    on<ReloadCameras>((event, emit) async {
      for (var c in state.displayedCameras) {
        c.isFavourite =
            _prefs!.getBool('${c.sortableName}${c.id}.isFavourite') ?? false;
        c.isVisible =
            _prefs!.getBool('${c.sortableName}${c.id}.isVisible') ?? true;
      }
      return emit(state.copyWith(
        displayedCameras: state.displayedCameras,
        showList: event.showList,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    on<SortCameras>((event, emit) async {
      switch (event.sortingMethod) {
        case SortingMethod.distance:
          var position = await LocationService.getCurrentLocation();
          var location = Location.fromPosition(position);
          _sortByDistance(location);
          break;
        case SortingMethod.neighbourhood:
          _sortByNeighbourhood();
          break;
        case SortingMethod.name:
        default:
          _sortByName();
          break;
      }
      return emit(state.copyWith(
        displayedCameras: state.displayedCameras,
        sortingMethod: event.sortingMethod,
      ));
    });

    on<SearchCameras>((event, emit) async {
      List<Camera> result = state.visibleCameras.toList();
      switch (event.searchMode) {
        case SearchMode.camera:
          result = _searchByCamera(event.query);
          break;
        case SearchMode.neighbourhood:
          result = _searchByNeighbourhood(event.query);
          break;
        case SearchMode.none:
        default:
          break;
      }
      return emit(state.copyWith(
        filterMode: FilterMode.visible,
        displayedCameras: result,
        searchMode: event.searchMode,
      ));
    });

    on<FilterCamera>((event, emit) async {
      List<Camera> displayedCameras;
      switch (event.filterMode) {
        case FilterMode.favourite:
          displayedCameras = state.favouriteCameras;
          break;
        case FilterMode.visible:
          displayedCameras = state.visibleCameras;
          break;
        case FilterMode.hidden:
          displayedCameras = state.hiddenCameras;
          break;
        default:
          displayedCameras = state.displayedCameras;
          break;
      }
      return emit(state.copyWith(
        searchMode: SearchMode.none,
        filterMode: event.filterMode,
        displayedCameras: displayedCameras,
      ));
    });

    on<SelectCamera>((event, emit) async {
      List<Camera> selectedCameras = state.selectedCameras.toList();
      if (selectedCameras.contains(event.camera)) {
        selectedCameras.remove(event.camera);
      } else {
        selectedCameras.add(event.camera);
      }
      return emit(state.copyWith(
        selectedCameras: selectedCameras,
      ));
    });

    on<SelectAll>((event, emit) async {
      return emit(state.copyWith(
        selectedCameras: state.displayedCameras,
      ));
    });

    on<ClearSelection>((event, emit) async {
      return emit(state.copyWith(
        selectedCameras: const [],
      ));
    });
  }

  void _sortByName() {
    state.displayedCameras
        .sort((a, b) => a.sortableName.compareTo(b.sortableName));
  }

  void _sortByDistance(Location location) {
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

  void _sortByNeighbourhood() {
    state.displayedCameras.sort((a, b) {
      int result = a.neighbourhood.compareTo(b.neighbourhood);
      if (a.neighbourhood.compareTo(b.neighbourhood) == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
  }

  List<Camera> _searchByCamera(String query) {
    List<Camera> result = state.visibleCameras;
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

  List<Camera> _searchByNeighbourhood(String query) {
    return state.visibleCameras
        .where((cam) =>
            cam.neighbourhood.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void favouriteSelectedCameras() {
    var allFave = state.selectedCameras.every((camera) => camera.isFavourite);
    for (var camera in state.selectedCameras) {
      camera.isFavourite = !allFave;
    }
    _writeSharedPrefs();
    add(ReloadCameras(showList: state.showList));
  }

  void hideSelectedCameras() {
    var allHidden = state.selectedCameras.every((camera) => !camera.isVisible);
    for (var camera in state.selectedCameras) {
      camera.isVisible = !allHidden;
    }
    _writeSharedPrefs();
    add(ReloadCameras(showList: state.showList));
  }

  void updateCamera(Camera camera) {
    for (Camera cam in state.allCameras) {
      if (cam == camera) {
        cam.isVisible = camera.isVisible;
        cam.isFavourite = camera.isFavourite;
      }
    }
    _writeSharedPrefs();
    add(ReloadCameras());
  }

  void changeCity(Cities city) {
    add(CameraLoading());
    _prefs?.setString('city', city.name);
    add(CameraLoaded());
  }

  void _writeSharedPrefs() {
    for (var camera in state.allCameras) {
      _prefs!.setBool(
        '${camera.sortableName}${camera.id}.isFavourite',
        camera.isFavourite,
      );
      _prefs!.setBool(
        '${camera.sortableName}${camera.id}.isVisible',
        camera.isVisible,
      );
    }
  }
}

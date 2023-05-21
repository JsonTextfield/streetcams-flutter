import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/services/location_service.dart';

import '../entities/Cities.dart';
import '../entities/bilingual_object.dart';
import '../entities/camera.dart';
import '../entities/location.dart';
import '../entities/neighbourhood.dart';

part 'camera_event.dart';

part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState>
    with WidgetsBindingObserver {
  SharedPreferences? _prefs;

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    BilingualObject.locale =
        locales?.first.languageCode ?? BilingualObject.locale;
    add(ReloadCameras(showList: state.showList));
  }

  CameraBloc() : super(const CameraState()) {
    WidgetsBinding.instance.addObserver(this);

    on<CameraLoading>((event, emit) async {
      _prefs ??= await SharedPreferences.getInstance();
      return emit(state.copyWith(
        status: CameraStatus.initial,
        searchMode: SearchMode.none,
        filterMode: FilterMode.visible,
      ));
    });

    on<CameraLoaded>((event, emit) async {
      BilingualObject.locale = await intl.findSystemLocale();
      _prefs ??= await SharedPreferences.getInstance();
      Cities city = Cities.ottawa;
      if (_prefs?.getString('city') != null &&
          _prefs!.getString('city')!.isNotEmpty) {
        String str = _prefs!.getString('city')!;
        city = Cities.values.firstWhere((Cities c) => describeEnum(c) == str);
      }
      List<dynamic> allData = await DownloadService.downloadAll(city);
      List<Camera> allCameras = allData.first;
      _readSharedPrefs(allCameras);
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
      _readSharedPrefs(state.displayedCameras);
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
      return emit(state.copyWith(selectedCameras: selectedCameras));
    });

    on<SelectAll>((event, emit) async {
      return emit(state.copyWith(selectedCameras: state.displayedCameras));
    });

    on<ClearSelection>((event, emit) async {
      return emit(state.copyWith(selectedCameras: const []));
    });
  }

  void _sortByName() {
    state.displayedCameras
        .sort((a, b) => a.sortableName.compareTo(b.sortableName));
  }

  String getDistanceString(double distance) {
    if (distance > 9000e3) {
      return '>9000\nkm';
    }
    if (distance >= 100e3) {
      return '${(distance / 1000).round()}\nkm';
    }
    if (distance >= 500) {
      distance = (distance / 100).roundToDouble() / 10;
      return '$distance\nkm';
    }
    return '${distance.round()}\nm';
  }

  void _sortByDistance(Location location) {
    state.displayedCameras.sort((a, b) {
      double distanceA = location.distanceTo(a.location);
      double distanceB = location.distanceTo(b.location);
      a.distance = getDistanceString(distanceA);
      b.distance = getDistanceString(distanceB);
      int result = distanceA.compareTo(distanceB);
      return result == 0 ? a.sortableName.compareTo(b.sortableName) : result;
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
    bool Function(Camera) predicate = (camera) => camera.isVisible;
    String q = query;
    if (q.startsWith('f:')) {
      q = q.substring(2).trim();
      predicate = (camera) => camera.isVisible && camera.isFavourite;
    } else if (q.startsWith('h:')) {
      q = q.substring(2).trim();
      predicate = (camera) => !camera.isVisible;
    }
    return state.allCameras
        .where(predicate)
        .where((camera) => !camera.name.containsIgnoreCase(q))
        .toList();
  }

  List<Camera> _searchByNeighbourhood(String query) {
    return state.visibleCameras
        .where((camera) => camera.neighbourhood.containsIgnoreCase(query))
        .toList();
  }

  void favouriteSelectedCameras() {
    bool allFave = state.selectedCameras.every((camera) => camera.isFavourite);
    for (Camera camera in state.selectedCameras) {
      camera.isFavourite = !allFave;
    }
    _writeSharedPrefs();
    add(ReloadCameras(showList: state.showList));
  }

  void hideSelectedCameras() {
    bool allHidden = state.selectedCameras.every((camera) => !camera.isVisible);
    for (Camera camera in state.selectedCameras) {
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
    for (Camera camera in state.allCameras) {
      _prefs!.setBool('${camera.cameraId}.isFavourite', camera.isFavourite);
      _prefs!.setBool('${camera.cameraId}.isVisible', camera.isVisible);
    }
  }

  void _readSharedPrefs(List<Camera> cameras) {
    for (Camera c in cameras) {
      c.isFavourite = _prefs!.getBool('${c.cameraId}.isFavourite') ?? false;
      c.isVisible = _prefs!.getBool('${c.cameraId}.isVisible') ?? true;
    }
  }
}

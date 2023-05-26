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

class LocaleListener with WidgetsBindingObserver {
  final void Function() callback;

  LocaleListener({required this.callback}) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    BilingualObject.locale =
        locales?.first.languageCode ?? BilingualObject.locale;
    callback.call();
  }
}

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  LocaleListener? localeListener;
  SharedPreferences? prefs;

  CameraBloc({
    this.localeListener,
    this.prefs,
  }) : super(const CameraState()) {
    localeListener ??= LocaleListener(callback: () {
      add(ReloadCameras(showList: state.showList));
    });

    on<CameraLoading>((event, emit) async {
      BilingualObject.locale = await intl.findSystemLocale();
      prefs ??= await SharedPreferences.getInstance();
      return emit(state.copyWith(
        status: CameraStatus.initial,
        searchMode: SearchMode.none,
        filterMode: FilterMode.visible,
      ));
    });

    on<CameraLoaded>((event, emit) async {
      BilingualObject.locale = await intl.findSystemLocale();
      prefs ??= await SharedPreferences.getInstance();
      Cities city = Cities.ottawa;
      if ((prefs?.getString('city') ?? '').isNotEmpty) {
        String str = prefs!.getString('city')!;
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
      _readSharedPrefs(state.allCameras);
      return emit(state.copyWith(
        displayedCameras: state.displayedCameras,
        allCameras: state.allCameras,
        showList: event.showList,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    on<SortCameras>((event, emit) async {
      await _sortCameras(event.sortingMethod);
      return emit(state.copyWith(
        displayedCameras: state.displayedCameras,
        sortingMethod: event.sortingMethod,
      ));
    });

    on<SearchCameras>((event, emit) async {
      return emit(state.copyWith(
        displayedCameras: _searchCameras(
          event.searchMode,
          state.filterMode,
          event.query,
        ),
        searchMode: event.searchMode,
      ));
    });

    on<FilterCamera>((event, emit) async {
      FilterMode mode = event.filterMode == state.filterMode
          ? FilterMode.visible
          : event.filterMode;
      return emit(state.copyWith(
        selectedCameras: [],
        searchMode: SearchMode.none,
        filterMode: mode,
        displayedCameras: _filterCameras(mode),
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

  List<Camera> _filterCameras(FilterMode filterMode) {
    switch (filterMode) {
      case FilterMode.favourite:
        return state.favouriteCameras;
      case FilterMode.visible:
        return state.visibleCameras;
      case FilterMode.hidden:
        return state.hiddenCameras;
      default:
        return state.displayedCameras;
    }
  }

  Future<void> _sortCameras(SortingMethod sortingMethod) async {
    switch (sortingMethod) {
      case SortingMethod.distance:
        var position = await LocationService.getCurrentLocation();
        var location = Location.fromPosition(position);
        for (Camera cam in state.allCameras) {
          cam.distance = getDistanceString(location.distanceTo(cam.location));
        }
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
      return result == 0 ? a.sortableName.compareTo(b.sortableName) : result;
    });
  }

  List<Camera> _searchCameras(
    SearchMode searchMode,
    FilterMode filterMode,
    String query,
  ) {
    return state.allCameras
        .where(_getFilterPredicate(filterMode))
        .where(_getSearchPredicate(searchMode, query))
        .toList();
  }

  bool Function(Camera) _getFilterPredicate(FilterMode filterMode) {
    switch (filterMode) {
      case FilterMode.favourite:
        return (camera) => camera.isFavourite;
      case FilterMode.hidden:
        return (camera) => !camera.isVisible;
      case FilterMode.visible:
      default:
        return (camera) => camera.isVisible;
    }
  }

  bool Function(Camera) _getSearchPredicate(SearchMode searchMode, String str) {
    switch (searchMode) {
      case SearchMode.camera:
        return (camera) => camera.name.containsIgnoreCase(str.trim());
      case SearchMode.neighbourhood:
        return (camera) => camera.neighbourhood.containsIgnoreCase(str.trim());
      case SearchMode.none:
      default:
        return (camera) => true;
    }
  }

  void favouriteSelectedCameras() {
    bool allFave = state.selectedCameras.every((camera) => camera.isFavourite);
    for (Camera camera in state.selectedCameras) {
      prefs?.setBool('${camera.cameraId}.isFavourite', !allFave);
    }
    add(ReloadCameras(showList: state.showList));
  }

  void hideSelectedCameras() {
    bool anyVisible = state.selectedCameras.any((camera) => camera.isVisible);
    for (Camera cam in state.selectedCameras) {
      cam.isVisible = !anyVisible;
      prefs?.setBool('${cam.cameraId}.isVisible', !anyVisible);
    }
    add(ReloadCameras(showList: state.showList));
    add(FilterCamera(filterMode: state.filterMode));
  }

  void updateCamera(Camera camera) {
    for (Camera cam in state.allCameras) {
      if (cam == camera) {
        cam.isVisible = camera.isVisible;
        prefs?.setBool('${camera.cameraId}.isVisible', camera.isVisible);
        cam.isFavourite = camera.isFavourite;
        prefs?.setBool('${camera.cameraId}.isFavourite', camera.isFavourite);
        break;
      }
    }
    add(ReloadCameras(showList: state.showList));
  }

  void changeCity(Cities city) {
    add(CameraLoading());
    prefs?.setString('city', city.name);
    add(CameraLoaded());
  }

  void _readSharedPrefs(List<Camera> cameras) {
    for (Camera c in cameras) {
      c.isFavourite = prefs?.getBool('${c.cameraId}.isFavourite') ?? false;
      c.isVisible = prefs?.getBool('${c.cameraId}.isVisible') ?? true;
    }
  }
}

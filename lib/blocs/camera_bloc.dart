import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/services/location_service.dart';

import '../entities/bilingual_object.dart';
import '../entities/camera.dart';
import '../entities/city.dart';
import '../entities/location.dart';

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
    callback();
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
      add(ReloadCameras(viewMode: ViewMode.list));
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
      City city = City.values.firstWhere(
        (City c) => c.name == prefs?.getString('city'),
        orElse: () => City.ottawa,
      );
      ViewMode viewMode = ViewMode.values.firstWhere(
        (ViewMode v) => v.name == prefs?.getString('viewMode'),
        orElse: () => ViewMode.gallery,
      );
      List<Camera> allCameras = [];
      try {
        allCameras = await DownloadService.downloadCameras(city);
      } on Exception catch (_) {
        return emit(state.copyWith(
          status: CameraStatus.failure,
        ));
      }
      _readSharedPrefs(allCameras);
      return emit(state.copyWith(
        displayedCameras: allCameras.where((cam) => cam.isVisible).toList(),
        allCameras: allCameras,
        status: CameraStatus.success,
        city: city,
        sortMode: SortMode.name,
        filterMode: FilterMode.visible,
        searchMode: SearchMode.none,
        viewMode: viewMode,
      ));
    });

    on<ReloadCameras>((event, emit) async {
      _readSharedPrefs(state.displayedCameras);
      _readSharedPrefs(state.allCameras);
      prefs?.setString('viewMode', event.viewMode.name);

      return emit(state.copyWith(
        displayedCameras: state.displayedCameras,
        allCameras: state.allCameras,
        viewMode: event.viewMode,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    on<SortCameras>((event, emit) async {
      await _sortCameras(event.sortMode);
      return emit(state.copyWith(
        displayedCameras: state.displayedCameras,
        sortMode: event.sortMode,
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

    on<ResetFilters>((event, emit) async {
      return emit(state.copyWith(
        displayedCameras:
            _searchCameras(SearchMode.none, FilterMode.visible, ''),
        selectedCameras: [],
        searchMode: SearchMode.none,
        filterMode: FilterMode.visible,
      ));
    });
  }

  List<Camera> _filterCameras(FilterMode filterMode) {
    return switch (filterMode) {
      FilterMode.favourite => state.favouriteCameras,
      FilterMode.visible => state.visibleCameras,
      FilterMode.hidden => state.hiddenCameras,
    };
  }

  Future<void> _sortCameras(SortMode sortMode) async {
    switch (sortMode) {
      case SortMode.distance:
        var position = await LocationService.getCurrentLocation();
        var location = Location.fromPosition(position);
        for (Camera cam in state.allCameras) {
          cam.distance = getDistanceString(location.distanceTo(cam.location));
        }
        _sortByDistance(location);
        break;
      case SortMode.neighbourhood:
        _sortByNeighbourhood();
        break;
      case SortMode.name:
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
    return _filterCameras(filterMode)
        .where(_getSearchPredicate(searchMode, query))
        .toList();
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

  void favouriteSelectedCameras(bool favourite) {
    for (Camera camera in state.selectedCameras) {
      prefs?.setBool('${camera.cameraId}.isFavourite', favourite);
    }
    add(ReloadCameras(viewMode: state.viewMode));
    add(FilterCamera(filterMode: state.filterMode));
    add(SortCameras(sortMode: state.sortMode));
  }

  void hideSelectedCameras(bool hide) {
    for (Camera cam in state.selectedCameras) {
      prefs?.setBool('${cam.cameraId}.isVisible', !hide);
    }
    add(ReloadCameras(viewMode: state.viewMode));
    add(FilterCamera(filterMode: state.filterMode));
    add(SortCameras(sortMode: state.sortMode));
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
    add(ReloadCameras(viewMode: state.viewMode));
  }

  void changeCity(City city) {
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

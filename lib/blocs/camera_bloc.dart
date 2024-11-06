import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/entities/latlon.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/services/location_service.dart';

part 'camera_event.dart';

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
    localeListener ??= LocaleListener(callback: () => add(ChangeViewMode()));

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
        allCameras = await DownloadService.getCameras(city);
        allCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
      } on Exception catch (_) {
        return emit(state.copyWith(status: CameraStatus.failure));
      }
      for (Camera c in allCameras) {
        c.isFavourite = prefs?.getBool('${c.cameraId}.isFavourite') ?? false;
        c.isVisible = prefs?.getBool('${c.cameraId}.isVisible') ?? true;
      }
      return emit(state.copyWith(
        displayedCameras: allCameras.where((cam) => cam.isVisible).toList(),
        allCameras: allCameras,
        status: CameraStatus.success,
        sortMode: SortMode.name,
        filterMode: FilterMode.visible,
        searchMode: SearchMode.none,
        searchText: '',
        city: city,
        viewMode: viewMode,
      ));
    });

    on<ChangeViewMode>((event, emit) async {
      prefs?.setString('viewMode', event.viewMode.name);
      return emit(state.copyWith(viewMode: event.viewMode));
    });

    on<ChangeTheme>((event, emit) async {
      prefs?.setString('theme', event.theme.name);
      return emit(state.copyWith(theme: event.theme));
    });

    on<SortCameras>((event, emit) async {
      if (event.sortMode == SortMode.distance) {
        var position = await LocationService.getCurrentLocation();
        var location = LatLon.fromPosition(position);
        for (Camera cam in state.allCameras) {
          cam.distance = location.distanceTo(cam.location);
        }
      }
      return emit(state.copyWith(
        sortMode: event.sortMode,
        displayedCameras: state.getDisplayedCameras(sortMode: event.sortMode),
      ));
    });

    on<SearchCameras>((event, emit) async {
      return emit(state.copyWith(
        displayedCameras: state.getDisplayedCameras(
          searchMode: event.searchMode,
          searchText: event.searchText,
        ),
        searchText: event.searchText,
        searchMode: event.searchMode,
      ));
    });

    on<FilterCamera>((event, emit) async {
      FilterMode mode = event.filterMode == state.filterMode
          ? FilterMode.visible
          : event.filterMode;
      return emit(state.copyWith(
        filterMode: mode,
        displayedCameras: state.getDisplayedCameras(filterMode: mode),
      ));
    });

    on<HideCameras>((event, emit) async {
      bool anyVisible = event.cameras.any((cam) => cam.isVisible);
      state.allCameras.where(event.cameras.contains).forEach((camera) {
        camera.isVisible = !anyVisible;
        prefs?.setBool('${camera.cameraId}.isVisible', !anyVisible);
      });
      return emit(state.copyWith(
        displayedCameras: state.getDisplayedCameras(),
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    on<FavouriteCameras>((event, emit) async {
      bool allFavourite = event.cameras.every((cam) => cam.isFavourite);
      state.allCameras.where(event.cameras.contains).forEach((camera) {
        camera.isFavourite = !allFavourite;
        prefs?.setBool('${camera.cameraId}.isFavourite', !allFavourite);
      });
      return emit(state.copyWith(
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    on<SelectCamera>((event, emit) async {
      for (Camera camera in state.allCameras) {
        if (camera == event.camera) {
          camera.isSelected = !camera.isSelected;
          break;
        }
      }
      return emit(state.copyWith(
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    on<SelectAll>((event, emit) async {
      state.allCameras
          .where(state.displayedCameras.contains)
          .forEach((camera) => camera.isSelected = event.select);
      return emit(state.copyWith(
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    on<ResetFilters>((event, emit) async {
      return emit(state.copyWith(
        displayedCameras: state.visibleCameras,
        searchMode: SearchMode.none,
        filterMode: FilterMode.visible,
      ));
    });

    on<ChangeCity>((event, emit) async {
      add(CameraLoading());
      prefs?.setString('city', event.city.name);
      add(CameraLoaded());
    });
  }
}

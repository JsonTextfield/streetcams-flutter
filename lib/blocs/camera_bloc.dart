import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart' as intl;
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/data/camera_repository.dart';
import 'package:streetcams_flutter/data/local_storage_data_source.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/entities/latlon.dart';
import 'package:streetcams_flutter/services/location_service.dart';

part 'camera_event.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState>
    with WidgetsBindingObserver {
  final ILocalStorageDataSource _prefs;
  final ICameraRepository _cameraRepository;

  CameraBloc(
    this._prefs,
    this._cameraRepository,
  ) : super(const CameraState()) {
    on<CameraLoading>((event, emit) async {
      String? savedCity = await _prefs.getString('city');
      City city = City.values.firstWhere(
        (City c) => c.name == savedCity,
        orElse: () => City.ottawa,
      );
      String? savedViewMode = await _prefs.getString('viewMode');
      ViewMode viewMode = ViewMode.values.firstWhere(
        (ViewMode v) => v.name == savedViewMode,
        orElse: () => ViewMode.gallery,
      );
      String? savedThemeMode = await _prefs.getString('theme');
      ThemeMode theme = ThemeMode.values.firstWhere(
        (ThemeMode t) => t.name == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
      emit(state.copyWith(
        uiState: UIState.loading,
        city: city,
        viewMode: viewMode,
        theme: theme,
      ));
      BilingualObject.locale = await intl.findSystemLocale();
      List<Camera> allCameras = [];
      try {
        allCameras = await _cameraRepository.getCameras(city);
        allCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
      } on Exception catch (_) {
        return emit(state.copyWith(uiState: UIState.failure));
      }
      for (Camera c in allCameras) {
        c.isFavourite =
            await _prefs.getBool('${c.cameraId}.isFavourite') ?? false;
        c.isVisible = await _prefs.getBool('${c.cameraId}.isVisible') ?? true;
      }
      return emit(state.copyWith(
        displayedCameras: allCameras.where((cam) => cam.isVisible).toList(),
        allCameras: allCameras,
        uiState: UIState.success,
        sortMode: SortMode.name,
        filterMode: FilterMode.visible,
        searchMode: SearchMode.none,
        searchText: '',
      ));
    });

    on<ChangeViewMode>((event, emit) async {
      _prefs.setString('viewMode', event.viewMode.name);
      return emit(state.copyWith(viewMode: event.viewMode));
    });

    on<ChangeTheme>((event, emit) async {
      _prefs.setString('theme', event.theme.name);
      return emit(state.copyWith(theme: event.theme));
    });

    on<ChangeCity>((event, emit) async {
      _prefs.setString('city', event.city.name);
      add(CameraLoading());
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
        _prefs.setBool('${camera.cameraId}.isVisible', !anyVisible);
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
        _prefs.setBool('${camera.cameraId}.isFavourite', !allFavourite);
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
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    BilingualObject.locale =
        locales?.firstOrNull?.languageCode ?? BilingualObject.locale;
    add(ChangeViewMode());
  }
}

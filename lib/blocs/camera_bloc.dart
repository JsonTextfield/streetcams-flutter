import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart'
    as intl;
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
  final IPreferencesDataSource _prefs;
  final ICameraRepository _cameraRepository;

  CameraBloc(this._prefs, this._cameraRepository) : super(const CameraState()) {
    on<CameraLoading>((event, emit) async {
      City city = await _prefs.getCity();
      ViewMode viewMode = await _prefs.getViewMode();
      ThemeMode theme = await _prefs.getTheme();
      emit(
        state.copyWith(
          uiState: UIState.loading,
          city: city,
          viewMode: viewMode,
          theme: theme,
        ),
      );
      BilingualObject.locale = await intl.findSystemLocale();
      List<Camera> allCameras = [];
      try {
        List<String> favourites = await _prefs.getFavourites();
        List<String> hidden = await _prefs.getHidden();
        allCameras =
            (await _cameraRepository.getCameras(city)).map((cam) {
              return cam.copyWith(
                isFavourite: favourites.contains(cam.cameraId),
                isVisible: !(hidden.contains(cam.cameraId)),
              );
            }).toList();
      } on Exception catch (_) {
        return emit(state.copyWith(uiState: UIState.failure));
      }
      return emit(
        state.copyWith(
          allCameras: allCameras,
          uiState: UIState.success,
          sortMode: SortMode.name,
          filterMode: FilterMode.visible,
          searchMode: SearchMode.none,
          searchText: '',
        ),
      );
    });

    on<ChangeViewMode>((event, emit) async {
      _prefs.setViewMode(event.viewMode);
      return emit(state.copyWith(viewMode: event.viewMode));
    });

    on<ChangeTheme>((event, emit) async {
      _prefs.setTheme(event.theme);
      return emit(state.copyWith(theme: event.theme));
    });

    on<ChangeCity>((event, emit) async {
      _prefs.setCity(event.city);
      add(CameraLoading());
    });

    on<SortCameras>((event, emit) async {
      List<Camera> updatedCameras = state.allCameras;
      if (event.sortMode == SortMode.distance) {
        var position = await LocationService.getCurrentLocation();
        var location = LatLon.fromPosition(position);
        updatedCameras =
            state.allCameras.map((camera) {
              return camera.copyWith(
                distance: location.distanceTo(camera.location),
              );
            }).toList();
      }
      return emit(
        state.copyWith(allCameras: updatedCameras, sortMode: event.sortMode),
      );
    });

    on<SearchCameras>((event, emit) async {
      return emit(
        state.copyWith(
          searchText: event.searchText,
          searchMode: event.searchMode,
        ),
      );
    });

    on<FilterCamera>((event, emit) async {
      FilterMode mode =
          event.filterMode == state.filterMode
              ? FilterMode.visible
              : event.filterMode;
      return emit(state.copyWith(filterMode: mode));
    });

    on<HideCameras>((event, emit) async {
      bool anyVisible = event.cameras.any((cam) => cam.isVisible);
      _prefs.setVisibility(
        event.cameras.map((cam) => cam.cameraId).toList(),
        !anyVisible,
      );
      List<String> hidden = await _prefs.getHidden();
      return emit(
        state.copyWith(
          allCameras:
              state.allCameras.map((camera) {
                return camera.copyWith(
                  isVisible: !hidden.contains(camera.cameraId),
                );
              }).toList(),
        ),
      );
    });

    on<FavouriteCameras>((event, emit) async {
      bool allFavourite = event.cameras.every((cam) => cam.isFavourite);
      _prefs.favourite(
        event.cameras.map((cam) => cam.cameraId).toList(),
        !allFavourite,
      );
      List<String> favourites = await _prefs.getFavourites();
      return emit(
        state.copyWith(
          allCameras:
              state.allCameras.map((camera) {
                return camera.copyWith(
                  isFavourite: favourites.contains(camera.cameraId),
                );
              }).toList(),
        ),
      );
    });

    on<SelectCamera>((event, emit) async {
      return emit(
        state.copyWith(
          allCameras:
              state.allCameras.map((camera) {
                if (camera == event.camera) {
                  return camera.copyWith(isSelected: !camera.isSelected);
                }
                return camera;
              }).toList(),
        ),
      );
    });

    on<SelectAll>((event, emit) async {
      List<Camera> displayedCameras = state.displayedCameras;
      state.allCameras
          .where(state.displayedCameras.contains)
          .forEach((camera) => camera.isSelected = event.select);
      return emit(
        state.copyWith(
          allCameras:
              state.allCameras.map((camera) {
                if (displayedCameras.contains(camera)) {
                  return camera.copyWith(isSelected: event.select);
                }
                return camera;
              }).toList(),
        ),
      );
    });

    on<ResetFilters>((event, emit) async {
      return emit(
        state.copyWith(
          searchMode: SearchMode.none,
          filterMode: FilterMode.visible,
        ),
      );
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

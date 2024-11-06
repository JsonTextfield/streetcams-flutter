import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';

part 'camera_state.freezed.dart';

enum CameraStatus { initial, success, failure }

enum SearchMode { none, camera, neighbourhood }

enum SortMode { name, distance, neighbourhood }

enum FilterMode { visible, hidden, favourite }

enum ViewMode { list, map, gallery }

@freezed
class CameraState with _$CameraState {
  const CameraState._();

  const factory CameraState({
    @Default(<Camera>[]) List<Camera> allCameras,
    @Default(<Camera>[]) List<Camera> displayedCameras,
    @Default(CameraStatus.initial) CameraStatus status,
    @Default(SortMode.name) SortMode sortMode,
    @Default(SearchMode.none) SearchMode searchMode,
    @Default('') String searchText,
    @Default(FilterMode.visible) FilterMode filterMode,
    @Default(ViewMode.gallery) ViewMode viewMode,
    @Default(0) int lastUpdated,
    @Default(City.ottawa) City city,
    @Default(ThemeMode.system) ThemeMode theme,
  }) = _CameraState;

  List<Camera> get selectedCameras =>
      allCameras.where((camera) => camera.isSelected).toList();

  List<Camera> get visibleCameras =>
      allCameras.where((camera) => camera.isVisible).toList();

  List<Camera> get hiddenCameras =>
      allCameras.where((camera) => !camera.isVisible).toList();

  List<Camera> get favouriteCameras =>
      allCameras.where((camera) => camera.isFavourite).toList();

  bool get showSectionIndex =>
      filterMode == FilterMode.visible &&
      sortMode == SortMode.name &&
      searchMode == SearchMode.none &&
      viewMode == ViewMode.list;

  bool get showSearchNeighbourhood =>
      status == CameraStatus.success && searchMode != SearchMode.neighbourhood;

  bool get showBackButton =>
      (filterMode != FilterMode.visible || searchMode != SearchMode.none) &&
      selectedCameras.isEmpty;

  List<String> get neighbourhoods =>
      allCameras.map((camera) => camera.neighbourhood).toSet().toList();

  bool Function(Camera) _getSearchPredicate(
    SearchMode searchMode,
    String searchText,
  ) {
    return switch (searchMode) {
      SearchMode.camera => (cam) =>
          cam.name.containsIgnoreCase(searchText.trim()),
      SearchMode.neighbourhood => (cam) =>
          cam.neighbourhood.containsIgnoreCase(searchText.trim()),
      SearchMode.none => (cam) => true,
    };
  }

  List<Camera> _getFilteredCameras(FilterMode filterMode) {
    return switch (filterMode) {
      FilterMode.favourite => favouriteCameras,
      FilterMode.visible => visibleCameras,
      FilterMode.hidden => hiddenCameras,
    };
  }

  int Function(Camera, Camera) _getCameraComparator(SortMode sortMode) {
    int sortByName(a, b) => a.sortableName.compareTo(b.sortableName);

    int sortByDistance(a, b) {
      int result = a.distance.compareTo(b.distance);
      return result == 0 ? sortByName(a, b) : result;
    }

    int sortByNeighbourhood(a, b) {
      int result = a.neighbourhood.compareTo(b.neighbourhood);
      return result == 0 ? sortByName(a, b) : result;
    }

    return switch (sortMode) {
      SortMode.name => sortByName,
      SortMode.distance => sortByDistance,
      SortMode.neighbourhood => sortByNeighbourhood,
    };
  }

  List<Camera> getDisplayedCameras({
    SearchMode? searchMode,
    FilterMode? filterMode,
    String? searchText,
    SortMode? sortMode,
  }) {
    searchMode ??= this.searchMode;
    filterMode ??= this.filterMode;
    searchText ??= this.searchText;
    sortMode ??= this.sortMode;
    return _getFilteredCameras(filterMode)
        .where(_getSearchPredicate(searchMode, searchText))
        .toList()
      ..sort(_getCameraComparator(sortMode));
  }
}

part of 'camera_bloc.dart';

enum CameraStatus { initial, success, failure }

enum SearchMode { none, camera, neighbourhood }

enum SortMode { name, distance, neighbourhood }

enum FilterMode { visible, hidden, favourite }

enum ViewMode { list, map, gallery }

class CameraState extends Equatable {
  final List<Camera> allCameras;
  final List<Camera> displayedCameras;
  final CameraStatus status;
  final SortMode sortMode;
  final SearchMode searchMode;
  final String searchText;
  final FilterMode filterMode;
  final ViewMode viewMode;
  final int lastUpdated;
  final City city;

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
      viewMode != ViewMode.map;

  bool get showSearchNeighbourhood =>
      status == CameraStatus.success &&
      searchMode != SearchMode.neighbourhood &&
      city != City.alberta &&
      city != City.ontario;

  bool get showBackButton =>
      (filterMode != FilterMode.visible || searchMode != SearchMode.none) &&
      selectedCameras.isEmpty;

  List<String> get neighbourhoods =>
      allCameras.map((camera) => camera.neighbourhood).toSet().toList();

  @override
  List<Object?> get props => [
        allCameras,
        displayedCameras,
        status,
        sortMode,
        searchText,
        searchMode,
        filterMode,
        viewMode,
        lastUpdated,
        city,
      ];

  const CameraState({
    this.allCameras = const <Camera>[],
    this.displayedCameras = const <Camera>[],
    this.status = CameraStatus.initial,
    this.sortMode = SortMode.name,
    this.searchMode = SearchMode.none,
    this.searchText = '',
    this.filterMode = FilterMode.visible,
    this.viewMode = ViewMode.gallery,
    this.lastUpdated = 0,
    this.city = City.ottawa,
  });

  CameraState copyWith({
    List<Camera>? allCameras,
    List<Camera>? displayedCameras,
    CameraStatus? status,
    SortMode? sortMode,
    SearchMode? searchMode,
    String? searchText,
    FilterMode? filterMode,
    ViewMode? viewMode,
    int? lastUpdated,
    City? city,
  }) {
    return CameraState(
      allCameras: allCameras ?? this.allCameras,
      displayedCameras: displayedCameras ?? this.displayedCameras,
      status: status ?? this.status,
      sortMode: sortMode ?? this.sortMode,
      searchMode: searchMode ?? this.searchMode,
      searchText: searchText ?? this.searchText,
      filterMode: filterMode ?? this.filterMode,
      viewMode: viewMode ?? this.viewMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      city: city ?? this.city,
    );
  }

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

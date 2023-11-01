part of 'camera_bloc.dart';

enum CameraStatus { initial, success, failure }

enum SearchMode { none, camera, neighbourhood }

enum SortMode { name, distance, neighbourhood }

enum FilterMode { visible, hidden, favourite }

enum ViewMode { list, map, gallery }

class CameraState extends Equatable {
  final List<Camera> allCameras;
  final List<Camera> displayedCameras;
  final List<Camera> selectedCameras;
  final CameraStatus status;
  final SortMode sortMode;
  final SearchMode searchMode;
  final FilterMode filterMode;
  final ViewMode viewMode;
  final int lastUpdated;
  final City city;

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

  @override
  List<Object?> get props => [
        allCameras,
        displayedCameras,
        selectedCameras,
        status,
        sortMode,
        searchMode,
        filterMode,
        viewMode,
        lastUpdated,
        city,
      ];

  const CameraState({
    this.allCameras = const <Camera>[],
    this.displayedCameras = const <Camera>[],
    this.selectedCameras = const <Camera>[],
    this.status = CameraStatus.initial,
    this.sortMode = SortMode.name,
    this.searchMode = SearchMode.none,
    this.filterMode = FilterMode.visible,
    this.viewMode = ViewMode.gallery,
    this.lastUpdated = 0,
    this.city = City.ottawa,
  });

  CameraState copyWith({
    List<Camera>? allCameras,
    List<Camera>? displayedCameras,
    List<Camera>? selectedCameras,
    CameraStatus? status,
    SortMode? sortMode,
    SearchMode? searchMode,
    FilterMode? filterMode,
    ViewMode? viewMode,
    int? lastUpdated,
    City? city,
  }) {
    return CameraState(
      allCameras: allCameras ?? this.allCameras,
      displayedCameras: displayedCameras ?? this.displayedCameras,
      selectedCameras: selectedCameras ?? this.selectedCameras,
      status: status ?? this.status,
      sortMode: sortMode ?? this.sortMode,
      searchMode: searchMode ?? this.searchMode,
      filterMode: filterMode ?? this.filterMode,
      viewMode: viewMode ?? this.viewMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      city: city ?? this.city,
    );
  }
}

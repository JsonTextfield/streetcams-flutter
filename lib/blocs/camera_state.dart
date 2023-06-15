part of 'camera_bloc.dart';

enum CameraStatus { initial, success, failure }

enum SearchMode { none, camera, neighbourhood }

enum SortingMethod { name, distance, neighbourhood }

enum FilterMode { visible, hidden, favourite }

enum ViewMode { list, gallery, map }

class CameraState extends Equatable {
  final List<Camera> allCameras;
  final List<Camera> displayedCameras;
  final List<Camera> selectedCameras;
  final List<Neighbourhood> neighbourhoods;
  final CameraStatus status;
  final SortingMethod sortingMethod;
  final SearchMode searchMode;
  final FilterMode filterMode;
  final ViewMode viewMode;
  final int lastUpdated;
  final Cities city;

  List<Camera> get visibleCameras =>
      allCameras.where((camera) => camera.isVisible).toList();

  List<Camera> get hiddenCameras =>
      allCameras.where((camera) => !camera.isVisible).toList();

  List<Camera> get favouriteCameras =>
      allCameras.where((camera) => camera.isFavourite).toList();

  bool get showSectionIndex =>
      filterMode == FilterMode.visible &&
      sortingMethod == SortingMethod.name &&
      searchMode == SearchMode.none &&
      viewMode == ViewMode.list;

  @override
  List<Object?> get props => [
        allCameras,
        displayedCameras,
        selectedCameras,
        neighbourhoods,
        status,
        sortingMethod,
        searchMode,
        filterMode,
        viewMode,
        lastUpdated,
        city,
      ];

  const CameraState({
    this.neighbourhoods = const <Neighbourhood>[],
    this.allCameras = const <Camera>[],
    this.displayedCameras = const <Camera>[],
    this.selectedCameras = const <Camera>[],
    this.status = CameraStatus.initial,
    this.sortingMethod = SortingMethod.name,
    this.searchMode = SearchMode.none,
    this.filterMode = FilterMode.visible,
    this.viewMode = ViewMode.gallery,
    this.lastUpdated = 0,
    this.city = Cities.ottawa,
  });

  CameraState copyWith({
    List<Neighbourhood>? neighbourhoods,
    List<Camera>? allCameras,
    List<Camera>? displayedCameras,
    List<Camera>? selectedCameras,
    CameraStatus? status,
    SortingMethod? sortingMethod,
    SearchMode? searchMode,
    FilterMode? filterMode,
    ViewMode? viewMode,
    int? lastUpdated,
    Cities? city,
  }) {
    return CameraState(
      neighbourhoods: neighbourhoods ?? this.neighbourhoods,
      allCameras: allCameras ?? this.allCameras,
      displayedCameras: displayedCameras ?? this.displayedCameras,
      selectedCameras: selectedCameras ?? this.selectedCameras,
      status: status ?? this.status,
      sortingMethod: sortingMethod ?? this.sortingMethod,
      searchMode: searchMode ?? this.searchMode,
      filterMode: filterMode ?? this.filterMode,
      viewMode: viewMode ?? this.viewMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      city: city ?? this.city,
    );
  }
}

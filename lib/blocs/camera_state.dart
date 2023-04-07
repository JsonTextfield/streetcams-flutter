part of 'camera_bloc.dart';

enum CameraStatus { initial, success, failure }

enum SearchMode { none, camera, neighbourhood }

enum SortMode { name, distance, neighbourhood }

enum FilterMode { visible, hidden, favourite }

class CameraState extends Equatable {
  final List<Camera> allCameras;
  final List<Camera> displayedCameras;
  final List<Camera> selectedCameras;
  final List<Neighbourhood> neighbourhoods;
  final CameraStatus status;
  final SortMode sortingMethod;
  final SearchMode searchMode;
  final FilterMode filterMode;
  final bool showList;
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
      sortingMethod == SortMode.name &&
      searchMode == SearchMode.none &&
      showList;

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
        showList,
        lastUpdated,
        city,
      ];

  const CameraState({
    this.neighbourhoods = const <Neighbourhood>[],
    this.allCameras = const <Camera>[],
    this.displayedCameras = const <Camera>[],
    this.selectedCameras = const <Camera>[],
    this.status = CameraStatus.initial,
    this.sortingMethod = SortMode.name,
    this.searchMode = SearchMode.none,
    this.filterMode = FilterMode.visible,
    this.showList = true,
    this.lastUpdated = 0,
    this.city = Cities.ottawa,
  });

  CameraState copyWith({
    bool? showList,
    List<Neighbourhood>? neighbourhoods,
    List<Camera>? allCameras,
    List<Camera>? displayedCameras,
    List<Camera>? selectedCameras,
    CameraStatus? status,
    SortMode? sortingMethod,
    SearchMode? searchMode,
    FilterMode? filterMode,
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
      showList: showList ?? this.showList,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      city: city ?? this.city,
    );
  }
}

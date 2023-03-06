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

  List<Camera> get visibleCameras =>
      allCameras.where((camera) => camera.isVisible).toList();

  List<Camera> get hiddenCameras =>
      allCameras.where((camera) => !camera.isVisible).toList();

  List<Camera> get favouriteCameras =>
      allCameras.where((camera) => camera.isFavourite).toList();

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
  });
}

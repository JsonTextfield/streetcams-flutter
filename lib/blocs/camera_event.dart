part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraLoading extends CameraEvent {}

class CameraLoaded extends CameraEvent {}

class ReloadCameras extends CameraEvent {
  final ViewMode viewMode;

  ReloadCameras({this.viewMode = ViewMode.list});

  @override
  List<Object?> get props => [viewMode];
}

class SortCameras extends CameraEvent {
  final SortMode sortMode;

  SortCameras({this.sortMode = SortMode.name});

  @override
  List<Object?> get props => [sortMode];
}

class SearchCameras extends CameraEvent {
  final SearchMode searchMode;
  final String query;

  SearchCameras({this.searchMode = SearchMode.camera, this.query = ''});

  @override
  List<Object?> get props => [searchMode, query];
}

class SelectCamera extends CameraEvent {
  final Camera camera;
  final List<Camera> selectedCameras;

  SelectCamera({required this.camera, this.selectedCameras = const <Camera>[]});

  @override
  List<Object?> get props => [camera, selectedCameras];
}

class ClearSelection extends CameraEvent {}

class SelectAll extends CameraEvent {}

class FilterCamera extends CameraEvent {
  final FilterMode filterMode;

  FilterCamera({this.filterMode = FilterMode.visible});

  @override
  List<Object?> get props => [filterMode];
}

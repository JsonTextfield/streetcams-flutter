part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraLoaded extends CameraEvent {
  final bool showList;

  CameraLoaded({this.showList = true});
}

class SortCameras extends CameraEvent {
  final SortMode method;

  SortCameras({this.method = SortMode.name});

  @override
  List<Object?> get props => [method];
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

class FilterCamera extends CameraEvent {
  final FilterMode filterMode;

  FilterCamera({this.filterMode = FilterMode.visible});

  @override
  List<Object?> get props => [filterMode];
}

part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraLoading extends CameraEvent {}

class CameraLoaded extends CameraEvent {
  final Cities city;

  CameraLoaded({this.city = Cities.ottawa});

  @override
  List<Object?> get props => [city];
}

class ReloadCameras extends CameraEvent {
  final bool showList;

  ReloadCameras({this.showList = true});

  @override
  List<Object?> get props => [showList];
}

class SortCameras extends CameraEvent {
  final SortingMethod sortingMethod;

  SortCameras({this.sortingMethod = SortingMethod.name});

  @override
  List<Object?> get props => [sortingMethod];
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

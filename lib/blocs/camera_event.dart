part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraLoading extends CameraEvent {}

class ChangeViewMode extends CameraEvent {
  final ViewMode viewMode;

  ChangeViewMode({this.viewMode = ViewMode.list});

  @override
  List<Object?> get props => [viewMode];
}

class ChangeTheme extends CameraEvent {
  final ThemeMode theme;

  ChangeTheme({this.theme = ThemeMode.system});

  @override
  List<Object?> get props => [theme];
}

class HideCameras extends CameraEvent {
  final List<Camera> cameras;

  HideCameras(this.cameras);

  @override
  List<Object?> get props => [cameras];
}

class FavouriteCameras extends CameraEvent {
  final List<Camera> cameras;

  FavouriteCameras(this.cameras);

  @override
  List<Object?> get props => [cameras];
}

class SortCameras extends CameraEvent {
  final SortMode sortMode;

  SortCameras({this.sortMode = SortMode.name});

  @override
  List<Object?> get props => [sortMode];
}

class ChangeCity extends CameraEvent {
  final City city;

  ChangeCity(this.city);

  @override
  List<Object?> get props => [city];
}

class SearchCameras extends CameraEvent {
  final SearchMode searchMode;
  final String searchText;

  SearchCameras({this.searchMode = SearchMode.camera, this.searchText = ''});

  @override
  List<Object?> get props => [searchMode, searchText];
}

class SelectCamera extends CameraEvent {
  final Camera camera;

  SelectCamera({required this.camera});

  @override
  List<Object?> get props => [camera];
}

class SelectAll extends CameraEvent {
  final bool select;

  SelectAll({this.select = true});

  @override
  List<Object?> get props => [select];
}

class ResetFilters extends CameraEvent {}

class FilterCamera extends CameraEvent {
  final FilterMode filterMode;

  FilterCamera({this.filterMode = FilterMode.visible});

  @override
  List<Object?> get props => [filterMode];
}

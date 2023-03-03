part of 'camera_bloc.dart';

enum CameraStatus { initial, success, failure }

enum CameraSortingMethod { name, distance, neighbourhood }

class CameraState extends Equatable {
  final List<Camera> allCameras;
  final CameraStatus status;
  final CameraSortingMethod sortingMethod;
  final SearchMode searchMode;

  @override
  List<Object?> get props => [allCameras, status, sortingMethod, searchMode];

  const CameraState({
    this.allCameras = const <Camera>[],
    this.status = CameraStatus.initial,
    this.sortingMethod = CameraSortingMethod.name,
    this.searchMode = SearchMode.none,
  });
}

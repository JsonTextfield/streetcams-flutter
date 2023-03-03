part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraLoaded extends CameraEvent {}

class SortCameras extends CameraEvent {
  final CameraSortingMethod method;
  SortCameras({this.method = CameraSortingMethod.name});

  @override
  List<Object?> get props => [method];
}

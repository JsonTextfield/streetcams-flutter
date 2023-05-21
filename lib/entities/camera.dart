import 'package:change_case/change_case.dart';
import 'package:equatable/equatable.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'Cities.dart';
import 'location.dart';

class Camera extends BilingualObject with EquatableMixin {
  String distance = '';
  bool isVisible = true;
  bool isFavourite = false;
  final int num;
  final Location location;
  String neighbourhood = '';
  String _url = '';
  final Cities city;

  Camera({
    this.num = 0,
    id = 0,
    required this.location,
    required this.city,
    nameEn = '',
    nameFr = '',
    url = '',
  }) : super(id: id, nameEn: nameEn, nameFr: nameFr) {
    _url = url;
  }

  factory Camera.fromJson(Map<String, dynamic> json, Cities city) {
    switch (city) {
      case Cities.toronto:
        return Camera._fromJsonToronto(json);
      case Cities.montreal:
        return Camera._fromJsonMontreal(json);
      case Cities.calgary:
        return Camera._fromJsonCalgary(json);
      case Cities.ottawa:
      default:
        return Camera._fromJsonOttawa(json);
    }
  }

  factory Camera._fromJsonOttawa(Map<String, dynamic> json) {
    return Camera(
      city: Cities.ottawa,
      num: json['number'] ?? 0,
      location: Location.fromJson(json),
      id: json['id'] ?? 0,
      nameEn: json['description'] ?? '',
      nameFr: json['descriptionFr'] ?? '',
    );
  }

  factory Camera._fromJsonToronto(Map<String, dynamic> json) {
    Map<String, dynamic> properties = json['properties'] ?? {};
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    Map<int, dynamic> coordinates = (geometry['coordinates'] ?? []).asMap();
    String mainRoad = properties['MAINROAD'] ?? 'Main St';
    String sideRoad = properties['CROSSROAD'] ?? 'Cross Rd';
    return Camera(
      city: Cities.toronto,
      num: properties['REC_ID'] ?? 0,
      location: Location.fromJsonArray(coordinates[0] ?? [0.0, 0.0]),
      id: properties['_id'] ?? 0,
      nameEn: '$mainRoad & $sideRoad'.toCapitalCase(),
    );
  }

  factory Camera._fromJsonMontreal(Map<String, dynamic> json) {
    Map<String, dynamic> properties = json['properties'] ?? {};
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    return Camera(
      city: Cities.montreal,
      location: Location.fromJsonArray(geometry['coordinates'] ?? [0.0, 0.0]),
      id: properties['id-camera'] ?? 0,
      nameFr: properties['titre'] ?? '',
      url: properties['url-image-en-direct'] ?? '',
    );
  }

  factory Camera._fromJsonCalgary(Map<String, dynamic> json) {
    Map<String, dynamic> point = json['point'] ?? {};
    Map<String, dynamic> cameraUrl = json['camera_url'] ?? {};
    return Camera(
      city: Cities.calgary,
      location: Location.fromJsonArray(point['coordinates'] ?? [0.0, 0.0]),
      nameEn: json['camera_location'] ?? '',
      url: cameraUrl['url'] ?? '',
    );
  }

  String get url {
    switch (city) {
      case Cities.toronto:
        return 'http://opendata.toronto.ca/transportation/tmc/rescucameraimages/CameraImages/loc$num.jpg';
      case Cities.montreal:
      case Cities.calgary:
        return _url;
      case Cities.ottawa:
      default:
        int time = DateTime.now().millisecondsSinceEpoch;
        return 'https://traffic.ottawa.ca/beta/camera?id=$num&timems=$time';
    }
  }

  @override
  List<Object?> get props => [nameEn, nameFr, num, id, location, city];

  String get cameraId => props.join();
}

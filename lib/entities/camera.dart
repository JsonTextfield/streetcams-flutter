import 'dart:math';

import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'Cities.dart';
import 'location.dart';

class Camera extends BilingualObject {
  bool isVisible = true;
  bool isFavourite = false;
  final int num;
  final Location location;
  String neighbourhood = '';
  String _url = '';
  final Cities city;

  Camera({
    required this.num,
    required this.location,
    required this.city,
    required id,
    required nameEn,
    required nameFr,
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
      nameEn: '$mainRoad & $sideRoad'.toTitleCase(),
      nameFr: '',
    );
  }

  factory Camera._fromJsonMontreal(Map<String, dynamic> json) {
    Map<String, dynamic> properties = json['properties'] ?? {};
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    return Camera(
      city: Cities.montreal,
      num: properties['id-camera'] ?? 0,
      location: Location.fromJsonArray(geometry['coordinates'] ?? [0.0, 0.0]),
      id: properties['id-camera'] ?? 0,
      nameEn: properties['titre'] ?? '',
      nameFr: '',
      url: properties['url-image-en-direct'] ?? '',
    );
  }

  factory Camera._fromJsonCalgary(Map<String, dynamic> json) {
    Map<String, dynamic> point = json['point'] ?? {};
    Map<String, dynamic> cameraUrl = json['camera_url'] ?? {};
    return Camera(
      city: Cities.calgary,
      num: Random().nextInt(100000),
      location: Location.fromJsonArray(point['coordinates'] ?? [0.0, 0.0]),
      id: Random().nextInt(1000000),
      nameEn: json['camera_location'] ?? '',
      nameFr: '',
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
  bool operator ==(Object other) {
    if (other is Camera) {
      return num == other.num && id == other.id;
    }
    return false;
  }

  @override
  int get hashCode {
    int prime = 31;
    int result = 1;
    result = prime * result + num.hashCode;
    result = prime * result + id.hashCode;
    return result;
  }

  @override
  String toString() => name;
}

extension StringExtension on String {
  String toTitleCase() {
    return toLowerCase()
        .split(' ')
        .map((word) => word.replaceFirst(word[0], word[0].toUpperCase()))
        .join(' ');
  }
}

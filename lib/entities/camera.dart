import 'dart:math';

import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'Cities.dart';
import 'location.dart';

class Camera extends BilingualObject {
  bool isVisible = true;
  bool isFavourite = false;
  final int num;
  final Location location;
  final String type;
  String neighbourhood = '';
  String _url = '';
  final Cities city;

  Camera({
    required this.num,
    required this.location,
    required this.type,
    required this.city,
    required id,
    required nameEn,
    required nameFr,
    url = '',
  }) : super(id: id, nameEn: nameEn, nameFr: nameFr) {
    _url = url;
  }

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      city: Cities.ottawa,
      num: json['number'] ?? 0,
      location: Location.fromJson(json),
      type: json['type'] ?? '',
      id: json['id'] ?? 0,
      nameEn: json['description'] ?? '',
      nameFr: json['descriptionFr'] ?? '',
    );
  }

  factory Camera.fromJsonToronto(Map<String, dynamic> json) {
    String jsonName = (json['properties']['MAINROAD'] +
            ' & ' +
            json['properties']['CROSSROAD']) ??
        '';
    String name = jsonName.toLowerCase().split(' ').map((word) {
      return word.replaceFirst(word[0], word[0].toUpperCase());
    }).join(' ');
    return Camera(
      city: Cities.toronto,
      num: json['properties']['REC_ID'] ?? 0,
      location: Location.fromJsonArray(json['geometry']['coordinates']),
      type: '',
      id: json['properties']['_id'] ?? 0,
      nameEn: name,
      nameFr: name,
    );
  }

  factory Camera.fromJsonMontreal(Map<String, dynamic> json) {
    return Camera(
      city: Cities.montreal,
      num: json['properties']['id-camera'] ?? 0,
      location: Location.fromJsonArray(json['geometry']['coordinates']),
      type: '',
      id: json['properties']['id-camera'] ?? 0,
      nameEn: json['properties']['titre'] ?? '',
      nameFr: json['properties']['titre'] ?? '',
      url: json['properties']['url-image-en-direct'] ?? '',
    );
  }

  factory Camera.fromJsonCalgary(Map<String, dynamic> json) {
    return Camera(
      city: Cities.montreal,
      num: Random().nextInt(1000000),
      location: Location.fromJsonArray(json['point']['coordinates']),
      type: '',
      id: Random().nextInt(1000000),
      nameEn: json['camera_location'] ?? '',
      nameFr: json['camera_location'] ?? '',
      url: json['camera_url']['url'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Camera) {
      return num == other.num && id == other.id;
    }
    return false;
  }

  String get url {
    switch (city) {
      case Cities.toronto:
        return 'http://opendata.toronto.ca/transportation/tmc/rescucameraimages/CameraImages/loc$num.jpg';
      case Cities.montreal:
        return _url;
      case Cities.ottawa:
      default:
        int time = DateTime.now().millisecondsSinceEpoch;
        return 'https://traffic.ottawa.ca/beta/camera?id=$num&timems=$time';
    }
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

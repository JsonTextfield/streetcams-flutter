import 'package:change_case/change_case.dart';
import 'package:equatable/equatable.dart';

import 'bilingual_object.dart';
import 'city.dart';
import 'location.dart';

class Camera extends BilingualObject with EquatableMixin {
  String distance = '';
  bool isVisible = true;
  bool isFavourite = false;
  final int num;
  final Location location;
  String neighbourhood = '';
  String _url = '';
  final City city;

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

  factory Camera.fromJson(dynamic json, City city) {
    return switch (city) {
      City.toronto => Camera._fromJsonToronto(json),
      City.montreal => Camera._fromJsonMontreal(json),
      City.calgary => Camera._fromJsonCalgary(json),
      City.ottawa => Camera._fromJsonOttawa(json),
      City.vancouver => Camera._fromJsonVancouver(json),
      City.surrey => Camera._fromJsonSurrey(json),
    };
  }

  factory Camera._fromJsonOttawa(Map<String, dynamic> json) {
    return Camera(
      city: City.ottawa,
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
      city: City.toronto,
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
      city: City.montreal,
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
      city: City.calgary,
      location: Location.fromJsonArray(point['coordinates'] ?? [0.0, 0.0]),
      nameEn: json['camera_location'] ?? '',
      url: cameraUrl['url'] ?? '',
    );
  }

  factory Camera._fromJsonVancouver(Map<String, dynamic> json) {
    Map<String, dynamic> geom = json['geom'] ?? {};
    Map<String, dynamic> geometry = geom['geometry'] ?? {};
    return Camera(
      city: City.vancouver,
      location: Location.fromJsonArray(geometry['coordinates'] ?? [0.0, 0.0]),
      nameEn: json['name'] ?? '',
      url: json['url'] ?? '',
    )..neighbourhood = json['geo_local_area'] ?? '';
  }

  factory Camera._fromJsonSurrey(List<dynamic> json) {
    return Camera(
      city: City.surrey,
      location: Location.fromJsonArray(
        [
          double.parse(json[4]),
          double.parse(json[5]),
        ],
      ),
      nameEn: json[1] ?? '',
      url: json[2] ?? '',
    );
  }

  @override
  String get sortableName {
    if (city != City.montreal) {
      return super.sortableName;
    }

    String sortableName = name;

    int startIndex = 0;
    if (sortableName.startsWith('Avenue ')) {
      startIndex = 'Avenue '.length;
    } //
    else if (sortableName.startsWith('Boulevard ')) {
      startIndex = 'Boulevard '.length;
    } //
    else if (sortableName.startsWith('Chemin ')) {
      startIndex = 'Chemin '.length;
    } //
    else if (sortableName.startsWith('Rue ')) {
      startIndex = 'Rue '.length;
    }
    sortableName = sortableName.substring(startIndex);

    var regex = RegExp('[0-9A-ZÀ-Ö]');
    return sortableName.substring(sortableName.indexOf(regex));
  }

  String get url {
    switch (city) {
      case City.toronto:
        return 'http://opendata.toronto.ca/transportation/tmc/rescucameraimages/CameraImages/loc$num.jpg';
      case City.montreal:
      case City.calgary:
      case City.vancouver:
      case City.surrey:
        return _url;
      case City.ottawa:
      default:
        int time = DateTime.now().millisecondsSinceEpoch;
        return 'https://traffic.ottawa.ca/beta/camera?id=$num&timems=$time';
    }
  }

  @override
  List<Object?> get props => [nameEn, nameFr, num, id, location, city];

  String get cameraId => props.join();
}

import 'package:change_case/change_case.dart';
import 'package:equatable/equatable.dart';

import 'bilingual_object.dart';
import 'city.dart';
import 'location.dart';

class Camera extends BilingualObject with EquatableMixin {
  String distance = '';
  bool isVisible = true;
  bool isFavourite = false;

  final City city;
  final int num;
  final Location location;

  String neighbourhood = '';
  String _url = '';

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
      City.surrey => Camera._fromJsonSurrey((json as List<dynamic>).asMap()),
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
      id: properties['_id'] ?? 0,
      nameEn: '$mainRoad & $sideRoad'.toCapitalCase(),
      location: Location.fromJsonArray(List<double>.from(coordinates[0])),
      url: properties['IMAGEURL'] ?? '',
    );
  }

  factory Camera._fromJsonMontreal(Map<String, dynamic> json) {
    Map<String, dynamic> properties = json['properties'] ?? {};
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    return Camera(
      city: City.montreal,
      id: properties['id-camera'] ?? 0,
      nameFr: properties['titre'] ?? '',
      location:
          Location.fromJsonArray(List<double>.from(geometry['coordinates'])),
      url: properties['url-image-en-direct'] ?? '',
    );
  }

  factory Camera._fromJsonCalgary(Map<String, dynamic> json) {
    Map<String, dynamic> point = json['point'] ?? {};
    Map<String, dynamic> cameraUrl = json['camera_url'] ?? {};
    return Camera(
      city: City.calgary,
      nameEn: json['camera_location'] ?? '',
      location: Location.fromJsonArray(List<double>.from(point['coordinates'])),
      url: cameraUrl['url'] ?? '',
    );
  }

  factory Camera._fromJsonVancouver(Map<String, dynamic> json) {
    Map<String, dynamic> geom = json['geom'] ?? {};
    Map<String, dynamic> geometry = geom['geometry'] ?? {};
    return Camera(
      city: City.vancouver,
      nameEn: json['name'] ?? '',
      location:
          Location.fromJsonArray(List<double>.from(geometry['coordinates'])),
      url: json['url'] ?? '',
    )..neighbourhood = json['geo_local_area'] ?? '';
  }

  factory Camera._fromJsonSurrey(Map<int, dynamic> json) {
    return Camera(
      city: City.surrey,
      id: json[0] ?? 0,
      nameEn: json[1] ?? '',
      location: Location.fromJsonArray(
        [
          double.tryParse(json[4] ?? '0.0') ?? 0.0,
          double.tryParse(json[5] ?? '0.0') ?? 0.0,
        ],
      ),
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
    if (city == City.ottawa) {
      int time = DateTime.now().millisecondsSinceEpoch;
      return 'https://traffic.ottawa.ca/beta/camera?id=$num&timems=$time';
    }
    return _url;
  }

  @override
  List<Object?> get props => [nameEn, nameFr, num, id, location, city];

  String get cameraId => props.join();
}

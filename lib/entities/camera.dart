import 'package:change_case/change_case.dart';
import 'package:equatable/equatable.dart';

import 'bilingual_object.dart';
import 'city.dart';
import 'location.dart';

class Camera extends BilingualObject with EquatableMixin {
  double distance = -1;
  bool isVisible = true;
  bool isFavourite = false;
  bool isSelected = false;

  final City city;
  final Location location;

  String neighbourhood = '';
  String _url = '';

  Camera({
    required this.location,
    required this.city,
    super.nameEn = '',
    super.nameFr = '',
    url = '',
    this.neighbourhood = '',
  }) {
    _url = url;
  }

  /*factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      nameEn: json['nameEn'] ?? '',
      nameFr: json['nameFr'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      neighbourhood: json['neighbourhood'] ?? '',
      url: json['url'] ?? '',
      city: City.values.firstWhere(
        (city) => city.name == json['city'],
        orElse: () => City.ottawa,
      ),
    );
  }*/

  factory Camera.fromJson(dynamic json, City city) {
    return switch (city) {
      City.toronto => Camera._fromJsonToronto(json),
      City.montreal => Camera._fromJsonMontreal(json),
      City.calgary => Camera._fromJsonCalgary(json),
      City.ottawa => Camera._fromJsonOttawa(json),
      City.vancouver => Camera._fromJsonVancouver(json),
      City.surrey => Camera._fromJsonSurrey((json as List<dynamic>).asMap()),
      City.ontario => Camera._fromJsonOntario(json),
      City.alberta => Camera._fromJsonAlberta(json),
    };
  }

  factory Camera._fromJsonOttawa(Map<String, dynamic> json) {
    return Camera(
        city: City.ottawa,
        location: Location.fromJson(json),
        nameEn: json['description'] ?? '',
        nameFr: json['descriptionFr'] ?? '',
        url: 'https://traffic.ottawa.ca/beta/camera?id=${json['number']}');
  }

  factory Camera._fromJsonToronto(Map<String, dynamic> json) {
    Map<String, dynamic> properties = json['properties'] ?? {};
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    Map<int, dynamic> coordinates = (geometry['coordinates'] ?? []).asMap();
    String mainRd = ((properties['MAINROAD'] ?? '') as String).toCapitalCase();
    String sideRd = ((properties['CROSSROAD'] ?? '') as String).toCapitalCase();
    return Camera(
      city: City.toronto,
      nameEn: '$mainRd & $sideRd',
      location: Location.fromJsonArray(
        List<double>.from(coordinates[0] ?? [0.0, 0.0]),
      ),
      url: properties['IMAGEURL'] ?? '',
    );
  }

  factory Camera._fromJsonMontreal(Map<String, dynamic> json) {
    Map<String, dynamic> properties = json['properties'] ?? {};
    Map<String, dynamic> geometry = json['geometry'] ?? {};
    return Camera(
      city: City.montreal,
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

  factory Camera._fromJsonOntario(Map<String, dynamic> json) {
    return Camera(
      city: City.ontario,
      nameEn: json['Name'] ?? '',
      nameFr: json['Description'] ?? '',
      location: Location(
        lat: json['Latitude'] ?? 0.0,
        lon: json['Longitude'] ?? 0.0,
      ),
      url: json['Url'] ?? '',
    );
  }

  factory Camera._fromJsonAlberta(Map<String, dynamic> json) {
    return Camera(
      city: City.alberta,
      nameEn: json['Name'] ?? '',
      location: Location(
        lat: json['Latitude'] ?? 0.0,
        lon: json['Longitude'] ?? 0.0,
      ),
      url: json['Url'] ?? '',
    );
  }

  @override
  String get sortableName {
    if (city != City.montreal) {
      return super.sortableName;
    }

    String sortableName = name;

    int startIndex = 0;

    for (String str in [
      'Avenue ',
      'Boulevard ',
      'Chemin ',
      'Rue ',
      'Place ',
    ]) {
      if (sortableName.startsWith(str)) {
        startIndex = str.length;
      }
    }
    sortableName = sortableName.substring(startIndex);

    var regex = RegExp('[0-9A-ZÀ-Ö]');
    return sortableName.substring(sortableName.indexOf(regex));
  }

  String get url {
    if (city == City.ottawa) {
      int time = DateTime.now().millisecondsSinceEpoch;
      return '$_url&timems=$time';
    }
    return _url;
  }

  String get distanceString {
    double distance = this.distance;
    if (distance > 9000e3) {
      return '>9000\nkm';
    }
    if (distance >= 100e3) {
      return '${(distance / 1000).round()}\nkm';
    }
    if (distance >= 500) {
      distance = (distance / 100).roundToDouble() / 10;
      return '$distance\nkm';
    }
    return '${distance.round()}\nm';
  }

  @override
  List<Object?> get props => [nameEn, nameFr, location, city];

  String get cameraId => props.join();
}

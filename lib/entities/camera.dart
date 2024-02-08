import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

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

  factory Camera.fromJson(Map<String, dynamic> json) {
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
  }

  factory Camera.fromCityData(dynamic data, City city) {
    return switch (city) {
      City.toronto => Camera._fromToronto(data),
      City.montreal => Camera._fromMontreal(data),
      City.calgary => Camera._fromCalgary(data),
      City.ottawa => Camera._fromOttawa(data),
      City.vancouver => Camera._fromVancouver(data),
      City.surrey => Camera._fromSurrey((data as List<dynamic>).asMap()),
      City.ontario => Camera._fromOntario(data),
      City.alberta => Camera._fromAlberta(data),
      City.britishColumbia => Camera._fromBritishColumbia(data),
    };
  }

  factory Camera._fromOttawa(Map<String, dynamic> camData) {
    return Camera(
        city: City.ottawa,
        location: Location.fromMap(camData),
        nameEn: camData['description'] ?? '',
        nameFr: camData['descriptionFr'] ?? '',
        url: 'https://traffic.ottawa.ca/beta/camera?id=${camData['number']}');
  }

  factory Camera._fromToronto(Map<String, dynamic> camData) {
    Map<String, dynamic> properties = camData['properties'] ?? {};
    Map<String, dynamic> geometry = camData['geometry'] ?? {};
    Map<int, dynamic> coordinates = (geometry['coordinates'] ?? []).asMap();
    String mainRd = (properties['MAINROAD'] ?? '').toCapitalCase();
    String sideRd = (properties['CROSSROAD'] ?? '').toCapitalCase();
    return Camera(
      city: City.toronto,
      nameEn: '$mainRd & $sideRd',
      location: Location.fromList(
        List<double>.from(coordinates[0] ?? [0.0, 0.0]),
      ),
      url: properties['IMAGEURL'] ?? '',
    );
  }

  factory Camera._fromMontreal(Map<String, dynamic> camData) {
    Map<String, dynamic> properties = camData['properties'] ?? {};
    Map<String, dynamic> geometry = camData['geometry'] ?? {};
    return Camera(
      city: City.montreal,
      nameFr: properties['titre'] ?? '',
      location: Location.fromList(List<double>.from(geometry['coordinates'])),
      url: properties['url-image-en-direct'] ?? '',
    );
  }

  factory Camera._fromCalgary(Map<String, dynamic> camData) {
    Map<String, dynamic> point = camData['point'] ?? {};
    Map<String, dynamic> cameraUrl = camData['camera_url'] ?? {};
    return Camera(
      city: City.calgary,
      nameEn: camData['camera_location'] ?? '',
      location: Location.fromList(List<double>.from(point['coordinates'])),
      url: cameraUrl['url'] ?? '',
    );
  }

  factory Camera._fromVancouver(Map<String, dynamic> camData) {
    Map<String, dynamic> geom = camData['geom'] ?? {};
    Map<String, dynamic> geometry = geom['geometry'] ?? {};
    return Camera(
        city: City.vancouver,
        nameEn: camData['name'] ?? '',
        location: Location.fromList(List<double>.from(geometry['coordinates'])),
        url: camData['url'] ?? '',
        neighbourhood: camData['geo_local_area'] ?? '');
  }

  factory Camera._fromSurrey(Map<int, dynamic> camData) {
    return Camera(
      city: City.surrey,
      nameEn: camData[1] ?? '',
      location: Location(
        lat: double.tryParse(camData[4]) ?? 0.0,
        lon: double.tryParse(camData[5]) ?? 0.0,
      ),
      url: camData[2] ?? '',
    );
  }

  factory Camera._fromOntario(Map<String, dynamic> camData) {
    return Camera(
      city: City.ontario,
      nameEn: camData['Name'] ?? '',
      nameFr: camData['Description'] ?? '',
      location: Location.fromMap(camData, useUppercase: true),
      url: camData['Url'] ?? '',
    );
  }

  factory Camera._fromAlberta(Map<String, dynamic> camData) {
    return Camera(
      city: City.alberta,
      nameEn: camData['Name'] ?? '',
      location: Location.fromMap(camData, useUppercase: true),
      url: camData['Url'] ?? '',
    );
  }

  factory Camera._fromBritishColumbia(Map<String, dynamic> camData) {
    return Camera(
      city: City.britishColumbia,
      nameEn: camData['camName'] ?? '',
      location: Location.fromMap(camData),
      url: camData['links_imageDisplay'] ?? '',
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

  String get fileName => '${name.replaceAll(
        RegExp('[^0-9A-ZÀ-Ö]', caseSensitive: false),
        '',
      )}${DateFormat('_yyyy_MM_dd_kk_mm_ss').format(DateTime.now())}.jpg';
}

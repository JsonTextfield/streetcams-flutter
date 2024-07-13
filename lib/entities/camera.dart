import 'package:equatable/equatable.dart';

import 'bilingual_object.dart';
import 'city.dart';
import 'latlon.dart';

class Camera with EquatableMixin {
  double distance = -1;
  bool isVisible = true;
  bool isFavourite = false;
  bool isSelected = false;

  final City city;
  final LatLon location;

  late final BilingualObject _name;
  String get name => _name.name;

  late final BilingualObject _neighbourhood;
  String get neighbourhood => _neighbourhood.name;

  String _url = '';

  Camera({
    required this.location,
    required this.city,
    name = const BilingualObject(en: '', fr: ''),
    neighbourhood = const BilingualObject(en: '', fr: ''),
    url = '',
  }) {
    _name = name;
    _neighbourhood = neighbourhood;
    _url = url;
  }

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      name: BilingualObject(
        en: json['nameEn'] ?? '',
        fr: json['nameFr'] ?? '',
      ),
      neighbourhood: BilingualObject(
        en: json['neighbourhoodEn'] ?? '',
        fr: json['neighbourhoodFr'] ?? '',
      ),
      location: LatLon.fromMap(json['location'] ?? {}),
      url: json['url'] ?? '',
      city: City.values.firstWhere(
        (city) => city.name == json['city'],
        orElse: () => City.ottawa,
      ),
    );
  }

  String get sortableName {
    if (city != City.quebec) {
      return _name.sortableName;
    }
    int startIndex = ['Avenue ', 'Boulevard ', 'Chemin ', 'Rue ', 'Place ']
        .firstWhere(name.startsWith, orElse: () => '')
        .length;
    String sortableName = name.substring(startIndex);
    return sortableName
        .substring(sortableName.indexOf(RegExp('[0-9A-ZÀ-Ö]')))
        .toUpperCase();
  }

  String get url {
    if (city == City.ottawa || city == City.quebec) {
      int time = DateTime.now().millisecondsSinceEpoch;
      return '$_url&timems=$time';
    }
    return _url;
  }

  String get preview => _url;

  String get distanceString {
    double distance = this.distance;

    if (distance < 0) {
      return '';
    }
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
  List<Object?> get props => [_name.en, _name.fr, location, city];

  String get cameraId => props.join();
}

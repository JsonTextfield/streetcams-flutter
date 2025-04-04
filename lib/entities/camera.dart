import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'bilingual_object.dart';
import 'city.dart';
import 'latlon.dart';

class Camera with EquatableMixin {
  final String id;
  final City city;
  final LatLon location;

  final double distance;
  final bool isVisible;
  final bool isFavourite;
  final bool isSelected;

  final BilingualObject _name;

  String get name => _name.name;

  final BilingualObject _neighbourhood;

  String get neighbourhood => _neighbourhood.name;

  final String _url;

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

  String get sortableName {
    if (city != City.quebec) {
      return _name.sortableName;
    }
    int startIndex =
        [
          'Avenue ',
          'Boulevard ',
          'Chemin ',
          'Rue ',
          'Place ',
        ].firstWhere(name.startsWith, orElse: () => '').length;
    String sortableName = name.substring(startIndex);
    return sortableName
        .substring(sortableName.indexOf(RegExp('[0-9A-ZÀ-Ö]')))
        .toUpperCase();
  }

  Camera({
    required this.id,
    required this.location,
    required this.city,
    name = const BilingualObject(),
    neighbourhood = const BilingualObject(),
    url = '',
    this.isFavourite = false,
    this.isVisible = true,
    this.isSelected = false,
    this.distance = -1,
  }) : _name = name,
       _neighbourhood = neighbourhood,
       _url = url;

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] ?? const Uuid().v4(),
      name: BilingualObject(en: json['nameEn'] ?? '', fr: json['nameFr'] ?? ''),
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

  Camera copyWith({
    String? id,
    City? city,
    LatLon? location,
    BilingualObject? name,
    BilingualObject? neighbourhood,
    String? url,
    double? distance,
    bool? isVisible,
    bool? isFavourite,
    bool? isSelected,
  }) {
    return Camera(
      id: id ?? this.id,
      location: location ?? this.location,
      city: city ?? this.city,
      name: name ?? _name,
      neighbourhood: neighbourhood ?? _neighbourhood,
      url: url ?? _url,
      distance: distance ?? this.distance,
      isVisible: isVisible ?? this.isVisible,
      isFavourite: isFavourite ?? this.isFavourite,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
    id,
    city,
    location,
    _name,
    _neighbourhood,
    _url,
    distance,
    isVisible,
    isFavourite,
    isSelected,
  ];

  @override
  String toString() {
    return name;
  }
}

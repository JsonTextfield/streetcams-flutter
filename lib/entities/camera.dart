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

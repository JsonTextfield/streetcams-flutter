import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'location.dart';

class Camera extends BilingualObject {
  bool isVisible = true;
  bool isFavourite = false;
  final int num;
  final Location location;
  final String type;
  String neighbourhood = '';

  Camera({
    required this.num,
    required this.location,
    required this.type,
    required id,
    required nameEn,
    required nameFr,
  }) : super(id: id, nameEn: nameEn, nameFr: nameFr);

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      num: json['number'] ?? 0,
      location: Location.fromJson(json),
      type: json['type'] ?? '',
      id: json['id'] ?? 0,
      nameEn: json['description'] ?? '',
      nameFr: json['descriptionFr'] ?? '',
    );
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

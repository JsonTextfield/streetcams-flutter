import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'location.dart';

class Camera extends BilingualObject {
  bool isHidden = false;
  bool isFavourite = false;
  final int num;
  final Location location;
  final String type;

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
        num: json['number'],
        location: Location.createFromJson(json),
        type: json['type'],
        id: json['id'],
        nameEn: json['description'],
        nameFr: json['descriptionFr']);
  }
}

import 'package:streetcams_flutter/bilingual_object.dart';

import 'location.dart';

class Camera extends BilingualObject {
  int num = 0;
  late final Location location;
  String type = '';

  Camera(Map<String, dynamic> json)
      : super(id: json['id'], nameEn: json['description'], nameFr: json['descriptionFr']) {
    num = json['number'];
    location = Location.createFromJson(json);
    type = json['type'];
  }
}

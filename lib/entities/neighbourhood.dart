import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'location.dart';

class Neighbourhood extends BilingualObject {
  final List<List<Location>> locations;

  const Neighbourhood({
    required this.locations,
    required id,
    required nameEn,
    required nameFr,
  }) : super(id: id, nameEn: nameEn, nameFr: nameFr);

  factory Neighbourhood.fromJson(Map<String, dynamic> json) {
    var areas = json['geometry']['coordinates'] as List<dynamic>;
    var coordinates = json['geometry']['coordinates'];
    bool hasMultipleParts = areas.length > 1;
    List<List<Location>> tempLocations = [];

    for (int i = 0; i < areas.length; i++) {
      var geometry = (hasMultipleParts ? coordinates[i][0] : coordinates[0])
          as List<dynamic>;
      List<Location> locationList = [];

      for (var jsonArray in geometry) {
        var location = Location.createFromJsonArray(jsonArray);
        locationList.add(location);
      }
      tempLocations.add(locationList);
    }
    return Neighbourhood(
        locations: tempLocations,
        id: json['properties']['ONS_ID'],
        nameEn: json['properties']['Name'],
        nameFr: json['properties']['Name_FR']);
  }
}

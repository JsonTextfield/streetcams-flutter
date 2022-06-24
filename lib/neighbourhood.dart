import 'package:streetcams_flutter/bilingual_object.dart';
import 'location.dart';

class Neighbourhood extends BilingualObject {
  List<List<Location>> locations = [];

  Neighbourhood(Map<String, dynamic> json)
      : super(
            id: json['properties']['ONS_ID'],
            nameEn: json['properties']['Name'],
            nameFr: json['properties']['Name_FR']) {
    var coordinates = json['geometry']['coordinates'] as List<dynamic>;
    // if this list contains more than 1 element, the area has multiple parts
    if (coordinates.length > 1) {
      for (int i = 0; i < coordinates.length; i++) {
        List<Location> tempList = [];
        var geometry = json['geometry']['coordinates'][i][0] as List<dynamic>;
        for (int i = 0; i < geometry.length; i++) {
          var location = Location.createFromJsonArray(geometry[i]);
          tempList.add(location);
        }
        locations.add(tempList);
      }
    } else {
      List<Location> tempList = [];
      var geometry = json['geometry']['coordinates'][0] as List<dynamic>;
      for (int i = 0; i < geometry.length; i++) {
        var location = Location.createFromJsonArray(geometry[i]);
        tempList.add(location);
      }
      locations.add(tempList);
    }
  }
}

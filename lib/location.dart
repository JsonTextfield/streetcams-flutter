class Location {
  final double lat;
  final double lon;

  const Location({
    required this.lat,
    required this.lon,
  });

  factory Location.createFromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['latitude'],
      lon: json['longitude'],
    );
  }
  factory Location.createFromJsonArray(List<dynamic> json) {
    return Location(
      lat: json[0],
      lon: json[1],
    );
  }

}
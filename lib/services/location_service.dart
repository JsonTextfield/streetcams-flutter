import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  /// Requests the location permission if location is enabled
  static Future<bool> requestPermission() async {
    // Test if location services are enabled.
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }

  static Future<Position> getCurrentLocation() async {
    if (!await requestPermission()) {
      return Future.error('Location unavailable');
    }
    return await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition();
  }
}

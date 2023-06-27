import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_map/plugin_api.dart' as flutter_map_api;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlon;

import '../../blocs/camera_bloc.dart';
import '../../constants.dart';
import '../../entities/camera.dart';
import '../../services/location_service.dart';

class MapWidget extends StatelessWidget {
  final List<Camera> cameras;
  final flutter_map.MapController flutterMapController =
      flutter_map.MapController();

  MapWidget({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    debugPrint('building map');
    if (defaultTargetPlatform == TargetPlatform.windows && !kIsWeb) {
      flutter_map.LatLngBounds? bounds = getBounds();
      List<flutter_map.Marker> markers = [];
      _getMapMarkers(context, markers);
      return flutter_map.FlutterMap(
        mapController: flutterMapController,
        options: flutter_map.MapOptions(
          bounds: bounds,
          boundsOptions: const flutter_map_api.FitBoundsOptions(inside: true),
          center: bounds?.center ?? latlon.LatLng(45.4, -75.7),
          minZoom: 9,
          maxZoom: 16,
        ),
        children: [
          flutter_map.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.jsontextfield.streetcams_flutter',
          ),
          flutter_map.MarkerLayer(markers: markers),
        ],
      );
    }
    return FutureBuilder<bool>(
      future: LocationService.requestPermission(),
      builder: (context, data) {
        LatLng initCamPos = const LatLng(45.4, -75.7);
        LatLngBounds? bounds = getBounds();
        Set<Marker> markers = {};
        _getMapMarkers(context, markers);

        if (data.hasData) {
          return FutureBuilder<String>(
            future: rootBundle.loadString('assets/dark_mode.json'),
            builder: (context, mapSnapshot) {
              if (mapSnapshot.hasData) {
                setDarkMode(GoogleMapController controller) {
                  if (Theme.of(context).brightness == Brightness.dark) {
                    controller.setMapStyle(mapSnapshot.data);
                  }
                }

                return GoogleMap(
                  myLocationEnabled: data.requireData,
                  cameraTargetBounds: CameraTargetBounds(bounds),
                  initialCameraPosition: CameraPosition(target: initCamPos),
                  minMaxZoomPreference: const MinMaxZoomPreference(9, 16),
                  markers: markers,
                  onMapCreated: setDarkMode,
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  List<double> getMinMaxLatLon() {
    if (cameras.isNotEmpty) {
      double minLat = cameras.first.location.lat;
      double maxLat = cameras.first.location.lat;
      double minLon = cameras.first.location.lon;
      double maxLon = cameras.first.location.lon;
      for (Camera camera in cameras) {
        minLat = min(minLat, camera.location.lat);
        maxLat = max(maxLat, camera.location.lat);
        minLon = min(minLon, camera.location.lon);
        maxLon = max(maxLon, camera.location.lon);
      }
      return [minLat, minLon, maxLat, maxLon];
    }
    return [];
  }

  dynamic getBounds() {
    var boundsList = getMinMaxLatLon();
    if (boundsList.isNotEmpty) {
      double minLat = boundsList[0];
      double minLon = boundsList[1];
      double maxLat = boundsList[2];
      double maxLon = boundsList[3];
      if (defaultTargetPlatform == TargetPlatform.windows && !kIsWeb) {
        return flutter_map.LatLngBounds(
          latlon.LatLng(minLat, minLon),
          latlon.LatLng(maxLat, maxLon),
        );
      }
      return LatLngBounds(
        southwest: LatLng(minLat, minLon),
        northeast: LatLng(maxLat, maxLon),
      );
    }
    return null;
  }

  void _getMapMarkers(BuildContext context, Iterable markers) {
    for (var camera in cameras) {
      if (markers is List<flutter_map.Marker>) {
        markers.add(
          flutter_map.Marker(
            point: latlon.LatLng(camera.location.lat, camera.location.lon),
            anchorPos: flutter_map.AnchorPos.exactly(
              flutter_map.Anchor(5.0, -20.0),
            ),
            builder: (context) => GestureDetector(
              child: Stack(
                children: [
                  Icon(
                    Icons.location_pin,
                    size: 48,
                    color: context
                            .read<CameraBloc>()
                            .state
                            .selectedCameras
                            .contains(camera)
                        ? Constants.accentColour
                        : camera.isFavourite
                            ? Colors.yellow
                            : Colors.red,
                  ),
                  const Icon(Icons.location_on_outlined, size: 48),
                ],
              ),
            ),
          ),
        );
      } else if (markers is Set<Marker>) {
        markers.add(
          Marker(
            icon: _getMarkerIcon(context, camera),
            markerId: MarkerId(camera.url),
            position: LatLng(camera.location.lat, camera.location.lon),
            infoWindow: InfoWindow(
              title: camera.name,
              onTap: () {
                context.read<CameraBloc>().add(SelectCamera(camera: camera));
              },
            ),
            zIndex: context
                    .read<CameraBloc>()
                    .state
                    .selectedCameras
                    .contains(camera)
                ? 1.0
                : 0.0,
          ),
        );
      }
    }
  }

  BitmapDescriptor _getMarkerIcon(BuildContext context, Camera camera) {
    if (context.read<CameraBloc>().state.selectedCameras.contains(camera)) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    if (camera.isFavourite) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
    return BitmapDescriptor.defaultMarker;
  }
}

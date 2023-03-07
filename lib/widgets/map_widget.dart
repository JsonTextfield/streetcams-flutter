import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_map/plugin_api.dart' as flutter_map_api;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlon;

import '../blocs/camera_bloc.dart';
import '../constants.dart';
import '../entities/camera.dart';
import '../services/location_service.dart';

class MapWidget extends StatelessWidget {
  final void Function(Camera) onTapped;
  final List<Camera> cameras;
  final flutter_map.MapController flutterMapController =
      flutter_map.MapController();

  MapWidget({
    super.key,
    required this.cameras,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      flutter_map.LatLngBounds boundsFlutterMaps = flutter_map.LatLngBounds();
      latlon.LatLng initCamPos = latlon.LatLng(45.4, -75.7);
      _getCameraPositionAndBounds(initCamPos, boundsFlutterMaps);
      List<flutter_map.Marker> markers = [];
      _getMapMarkers(context, markers);
      return flutter_map.FlutterMap(
        mapController: flutterMapController,
        options: flutter_map.MapOptions(
          onMapReady: () {
            if (boundsFlutterMaps != null) {
              flutterMapController.fitBounds(boundsFlutterMaps);
            }
          },
          bounds: boundsFlutterMaps,
          boundsOptions: const flutter_map_api.FitBoundsOptions(inside: true),
          center: initCamPos,
          minZoom: 9,
          maxZoom: 16,
        ),
        children: [
          flutter_map.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.jsontextfield.streetcams_flutter',
          ),
          flutter_map.MarkerLayer(
            markers: markers,
          ),
        ],
      );
    }
    LatLngBounds bounds = LatLngBounds(
      southwest: const LatLng(45.4, -75.7),
      northeast: const LatLng(45.4, -75.7),
    );
    return FutureBuilder<String>(
      future: _loadMapStyle(),
      builder: (context, mapSnapshot) {
        return FutureBuilder<Position>(
          future: LocationService.getCurrentLocation(),
          builder: (context, data) {
            LatLng initialCameraPosition = const LatLng(45.4, -75.7);
            _getCameraPositionAndBounds(initialCameraPosition, bounds);
            bool showLocation = data.hasData;
            Set<Marker> markers = {};
            _getMapMarkers(context, markers);
            return GoogleMap(
              myLocationButtonEnabled: showLocation,
              myLocationEnabled: showLocation,
              cameraTargetBounds: CameraTargetBounds(bounds),
              initialCameraPosition:
                  CameraPosition(target: initialCameraPosition),
              minMaxZoomPreference: const MinMaxZoomPreference(9, 16),
              markers: markers,
              onMapCreated: (controller) {
                if (Theme.of(context).brightness == Brightness.dark &&
                    mapSnapshot.hasData) {
                  controller.setMapStyle(mapSnapshot.data);
                }
              },
            );
          },
        );
      },
    );
  }

  void _getCameraPositionAndBounds(Object cameraPosition, Object bounds) {
    if (cameras.isNotEmpty) {
      var minLat = cameras[0].location.lat;
      var maxLat = cameras[0].location.lat;
      var minLon = cameras[0].location.lon;
      var maxLon = cameras[0].location.lon;
      for (var camera in cameras) {
        minLat = min(minLat, camera.location.lat);
        maxLat = max(maxLat, camera.location.lat);
        minLon = min(minLon, camera.location.lon);
        maxLon = max(maxLon, camera.location.lon);
      }
      if (cameraPosition is LatLng) {
        cameraPosition = LatLng(
          (minLat + maxLat) / 2,
          (minLon + maxLon) / 2,
        );
      } else if (cameraPosition is latlon.LatLng) {
        cameraPosition = latlon.LatLng(
          (minLat + maxLat) / 2,
          (minLon + maxLon) / 2,
        );
      }
      if (bounds is LatLngBounds) {
        bounds = LatLngBounds(
          southwest: LatLng(minLat, minLon),
          northeast: LatLng(maxLat, maxLon),
        );
      } else if (bounds is flutter_map.LatLngBounds) {
        bounds = flutter_map.LatLngBounds.fromPoints([
          latlon.LatLng(minLat, minLon),
          latlon.LatLng(maxLat, maxLon),
        ]);
      }
    }
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
                  const Icon(
                    Icons.location_on_outlined,
                    size: 48,
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (markers is Set<Marker>) {
        markers.add(
          Marker(
            icon: _getMarkerIcon(context, camera),
            markerId: MarkerId(camera.id.toString()),
            position: LatLng(camera.location.lat, camera.location.lon),
            infoWindow: InfoWindow(
              title: camera.name,
              onTap: () => onTapped.call(camera),
            ),
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

  Future<String> _loadMapStyle() async {
    return await rootBundle.loadString('assets/dark_mode.json');
  }
}

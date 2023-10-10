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
import '../../entities/city.dart';

class MapWidget extends StatelessWidget {
  final List<Camera> cameras;
  final flutter_map.MapController flutterMapController =
      flutter_map.MapController();
  final void Function(Camera)? onItemClick;
  final void Function(Camera)? onItemLongClick;

  MapWidget({
    super.key,
    required this.cameras,
    this.onItemClick,
    this.onItemLongClick,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('building map');
    City city = context.read<CameraBloc>().state.city;
    if (defaultTargetPlatform == TargetPlatform.windows && !kIsWeb) {
      flutter_map.LatLngBounds? bounds = getBounds();
      List<flutter_map.Marker> markers = [];
      _getMapMarkers(context, markers);
      latlon.LatLng initCamPos = bounds?.center ??
          switch (city) {
            City.ottawa => latlon.LatLng(45.424722, -75.695),
            City.toronto => latlon.LatLng(43.741667, -79.373333),
            City.montreal => latlon.LatLng(45.508889, -73.554167),
            City.calgary => latlon.LatLng(51.05, -114.066667),
            City.vancouver => latlon.LatLng(49.258513387198, -123.1012956358),
            City.surrey => latlon.LatLng(49.058513387198, -123.1012956358),
          };
      return flutter_map.FlutterMap(
        mapController: flutterMapController,
        options: flutter_map.MapOptions(
          bounds: bounds,
          boundsOptions: const flutter_map_api.FitBoundsOptions(
            inside: true,
            padding: EdgeInsets.all(50),
          ),
          center: initCamPos,
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
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/dark_mode.json'),
      builder: (context, data) {
        LatLngBounds? bounds = getBounds();

        LatLng initCamPos = bounds?.centre ??
            switch (city) {
              City.ottawa => const LatLng(45.424722, -75.695),
              City.toronto => const LatLng(43.741667, -79.373333),
              City.montreal => const LatLng(45.508889, -73.554167),
              City.calgary => const LatLng(51.05, -114.066667),
              City.vancouver => const LatLng(49.258513387198, -123.1012956358),
              City.surrey => const LatLng(49.058513387198, -123.1012956358),
            };

        Set<Marker> markers = {};
        _getMapMarkers(context, markers);

        if (data.hasData) {
          setDarkMode(GoogleMapController controller) {
            if (Theme.of(context).brightness == Brightness.dark) {
              controller.setMapStyle(data.data);
            }
          }

          return GoogleMap(
            cameraTargetBounds: CameraTargetBounds(bounds),
            initialCameraPosition: CameraPosition(
              target: initCamPos,
              zoom: 10,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(9, 16),
            markers: markers,
            onMapCreated: setDarkMode,
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
            markerId: MarkerId(camera.cameraId),
            position: LatLng(camera.location.lat, camera.location.lon),
            infoWindow: InfoWindow(
              title: camera.name,
              onTap: () => onItemLongClick?.call(camera),
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

extension on LatLngBounds {
  LatLng get centre => LatLng(
        (northeast.latitude + southwest.latitude) / 2,
        (northeast.longitude + southwest.longitude) / 2,
      );
}

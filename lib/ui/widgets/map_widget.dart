import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:streetcams_flutter/entities/city.dart';

import '../../blocs/camera_bloc.dart';
import '../../entities/camera.dart';

class MapWidget extends StatelessWidget {
  final List<Camera> cameras;
  final void Function(Camera)? onItemClick;
  final void Function(Camera)? onItemLongClick;

  const MapWidget({
    super.key,
    required this.cameras,
    this.onItemClick,
    this.onItemLongClick,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('building map');
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/dark_mode.json'),
      builder: (context, data) {
        if (data.hasData) {
          City city = context.read<CameraBloc>().state.city;
          LatLngBounds? bounds = _getBounds();
          LatLng initCamPos = bounds?.centre ?? const LatLng(0, 0);
          Set<Marker> markers = _getMapMarkers(context);

          return GoogleMap(
            cameraTargetBounds: CameraTargetBounds(bounds),
            initialCameraPosition: CameraPosition(
              target: initCamPos,
              zoom: switch (city) {
                City.ottawa ||
                City.toronto ||
                City.montreal ||
                City.calgary ||
                City.vancouver ||
                City.surrey =>
                  10,
                _ => 5,
              },
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(5, 16),
            markers: markers,
            onMapCreated: (controller) {
              if (Theme.of(context).brightness == Brightness.dark) {
                controller.setMapStyle(data.data);
              }
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  LatLngBounds? _getBounds() {
    if (cameras.isEmpty) {
      return null;
    }
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
    return LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );
  }

  Set<Marker> _getMapMarkers(BuildContext context) {
    return cameras.map((camera) {
      return Marker(
        icon: _getMarkerIcon(context, camera),
        markerId: MarkerId(camera.cameraId),
        position: LatLng(camera.location.lat, camera.location.lon),
        infoWindow: InfoWindow(
          title: camera.name,
          snippet: camera.neighbourhood.isEmpty ? null : camera.neighbourhood,
          onTap: () => onItemLongClick?.call(camera),
        ),
        zIndex:
            context.read<CameraBloc>().state.selectedCameras.contains(camera)
                ? 1.0
                : 0.0,
      );
    }).toSet();
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

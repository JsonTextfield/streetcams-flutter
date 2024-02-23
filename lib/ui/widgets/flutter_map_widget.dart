import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/constants.dart';
import 'package:streetcams_flutter/entities/camera.dart';

class FlutterMapWidget extends StatelessWidget {
  final List<Camera> cameras;
  final void Function(Camera)? onItemClick;
  final void Function(Camera)? onItemLongClick;

  const FlutterMapWidget({
    super.key,
    required this.cameras,
    this.onItemClick,
    this.onItemLongClick,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('building map');
    LatLngBounds? bounds = _getBounds();
    List<Marker> markers = _getMapMarkers(context);
    LatLng initCamPos = bounds?.center ?? const LatLng(0, 0);
    return FlutterMap(
      options: MapOptions(
        initialCameraFit: bounds != null
            ? CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50),
              )
            : null,
        initialCenter: initCamPos,
        minZoom: 5,
        maxZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jsontextfield.streetcams_flutter',
        ),
        MarkerLayer(markers: markers),
      ],
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
      LatLng(minLat, minLon),
      LatLng(maxLat, maxLon),
    );
  }

  List<Marker> _getMapMarkers(BuildContext context) {
    return cameras.map((camera) {
      return Marker(
        point: LatLng(camera.location.lat, camera.location.lon),
        child: GestureDetector(
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
          onTap: () => onItemClick?.call(camera),
          onLongPress: () => onItemLongClick?.call(camera),
        ),
      );
    }).toList();
  }
}

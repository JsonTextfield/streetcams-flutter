import 'dart:ui';

import 'package:flutter/material.dart';

import '../../entities/camera.dart';
import '../../entities/city.dart';

class CameraWidget extends StatelessWidget {
  // Widget for an individual camera feed
  final Camera camera;
  final String otherUrl;

  const CameraWidget(this.camera, {super.key, this.otherUrl = ''});

  @override
  Widget build(BuildContext context) {
    debugPrint('building camera widget');
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height -
            MediaQueryData.fromView(View.of(context)).padding.top,
      ),
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
              tileMode: TileMode.decal,
            ),
            child: Image.network(
              camera.city == City.vancouver ? otherUrl : camera.url,
              fit: BoxFit.fitWidth,
              gaplessPlayback: true,
              width: MediaQuery.sizeOf(context).width,
            ),
          ),
          Image.network(
            camera.city == City.vancouver ? otherUrl : camera.url,
            errorBuilder: (context, exception, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(50),
                width: MediaQuery.sizeOf(context).width,
                child: const Text(
                  'Image unavailable 😢',
                  textAlign: TextAlign.center,
                ),
              );
            },
            semanticLabel: camera.name,
            fit: BoxFit.contain,
            width: MediaQuery.sizeOf(context).width,
            gaplessPlayback: true,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                child: Text(
                  camera.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

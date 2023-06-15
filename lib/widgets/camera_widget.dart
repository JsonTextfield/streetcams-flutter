import 'dart:ui';

import 'package:flutter/material.dart';

import '../entities/camera.dart';

class CameraWidget extends StatelessWidget {
  // Widget for an individual camera feed
  final Camera camera;

  const CameraWidget(this.camera, {super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building camera widget');
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height -
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
              camera.url,
              fit: BoxFit.fitWidth,
              gaplessPlayback: true,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Image.network(
            camera.url,
            errorBuilder: (context, exception, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(50),
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Image unavailable 😢',
                  textAlign: TextAlign.center,
                ),
              );
            },
            semanticLabel: camera.name,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
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
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(10),
                child: Text(
                  camera.name,
                  style: const TextStyle(color: Colors.white),
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

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
            MediaQueryData.fromWindow(window).padding.top,
      ),
      child: Stack(
        children: [
          Image.network(
            camera.url,
            errorBuilder: (
              BuildContext context,
              Object exception,
              StackTrace? stackTrace,
            ) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Could not load image 😢',
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
                color: Colors.black45,
                child: Text(
                  camera.name,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

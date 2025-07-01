import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:video_player/video_player.dart';

import '../../entities/camera.dart';
import '../../entities/city.dart';
import '../../services/download_service.dart';
import 'camera_video_widget.dart';

class CameraWidget extends StatelessWidget {
  // Widget for an individual camera feed
  final Camera camera;

  const CameraWidget(this.camera, {super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building camera widget');
    if (camera.city == City.quebec) {
      VideoPlayerController vpc = VideoPlayerController.networkUrl(
        Uri.parse(camera.url),
      );
      return CameraVideoWidget(camera: camera, controller: vpc);
    }
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height),
      child: InkWell(
        onLongPress: () async {
          if (defaultTargetPlatform != TargetPlatform.iOS) {
            bool result = await DownloadService.saveImage(camera);
            if (result) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.translation.imageSaved(camera.name)),
                ),
              );
            }
          }
        },
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
                width: MediaQuery.sizeOf(context).width,
                errorBuilder: (context, exception, stacktrace) {
                  return const SizedBox();
                },
              ),
            ),
            Image.network(
              camera.url,
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Center(
                    child: Icon(
                      Icons.videocam_off_rounded,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                child: CameraLabel(camera.name),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraLabel extends StatelessWidget {
  final String title;

  const CameraLabel(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

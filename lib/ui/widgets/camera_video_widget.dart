import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../entities/camera.dart';

class CameraVideoWidget extends StatelessWidget {
  final Camera camera;
  final VideoPlayerController controller;

  const CameraVideoWidget({
    super.key,
    required this.camera,
    required this.controller,
  });

  Future<void> playVideo() async {
    await controller.initialize();
    await controller.setLooping(true);
    return controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height -
            MediaQueryData.fromView(View.of(context)).padding.top,
      ),
      child: Stack(
        textDirection: TextDirection.ltr,
        children: [
          FutureBuilder(
            future: playVideo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width /
                          controller.value.aspectRatio,
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
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

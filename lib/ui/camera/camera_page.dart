import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:video_player/video_player.dart';

import '../../entities/bilingual_object.dart';
import '../../entities/camera.dart';
import '../../entities/city.dart';
import 'camera_video_widget.dart';
import 'camera_widget.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/cameraPage';
  final bool isShuffling;
  final List<Camera> cameras;

  const CameraPage({
    super.key,
    required this.isShuffling,
    required this.cameras,
  });

  @override
  State<CameraPage> createState() => _CameraState();
}

class _CameraState extends State<CameraPage> with WidgetsBindingObserver {
  Timer? timer;
  PageController? controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    BilingualObject.locale =
        locales?.first.languageCode ?? BilingualObject.locale;
  }

  @override
  Widget build(BuildContext context) {
    controller =
        controller ??
        PageController(
          initialPage: context
              .read<CameraBloc>()
              .state
              .displayedCameras
              .indexWhere((camera) {
                return camera.id == widget.cameras.first.id;
              }),
          keepPage: true,
        );
    bool shuffle = widget.isShuffling;
    if (shuffle) {
      widget.cameras.shuffle();
    }
    timer ??= Timer.periodic(
      Duration(
        seconds:
            shuffle
                ? 6
                : widget.cameras.first.city == City.quebec
                ? 30
                : 3,
      ),
      (t) => setState(() {}),
    );
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<Camera>>(
            future: Future(() async {
              if (widget.cameras.isNotEmpty &&
                  widget.cameras.first.city == City.vancouver) {
                return await DownloadService.getVancouverCameras(
                  widget.cameras,
                );
              }
              return widget.cameras;
            }),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              List<Camera> cameras = snapshot.requireData;
              if (cameras.length == 1 && !shuffle) {
                return PageView(
                  controller: controller,
                  children:
                      context.read<CameraBloc>().state.displayedCameras.map((
                        camera,
                      ) {
                        return ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            camera.city == City.quebec
                                ? CameraVideoWidget(
                                  camera: camera,
                                  controller: VideoPlayerController.networkUrl(
                                    Uri.parse(camera.url),
                                  ),
                                )
                                : CameraWidget(camera),
                          ],
                        );
                      }).toList(),
                );
              }
              return ListView(
                children:
                    shuffle
                        ? [
                          CameraWidget(
                            cameras[Random().nextInt(cameras.length)],
                          ),
                        ]
                        : cameras
                            .map((camera) => CameraWidget(camera))
                            .toList(),
              );
            },
          ),
          const SafeArea(child: BackButton()),
          Container(
            height: MediaQuery.of(context).padding.top,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withAlpha(128)
                      : Colors.white.withAlpha(128),
            ),
          ),
        ],
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white54,
      ),
      margin: const EdgeInsets.all(5),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: context.translation.back,
        color: Colors.black,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

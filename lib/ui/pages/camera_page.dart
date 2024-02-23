import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:video_player/video_player.dart';

import '../../entities/bilingual_object.dart';
import '../../entities/camera.dart';
import '../../entities/city.dart';
import '../widgets/camera_video_widget.dart';
import '../widgets/camera_widget.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/cameraPage';

  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraState();
}

class _CameraState extends State<CameraPage> with WidgetsBindingObserver {
  Timer? timer;
  List<Camera> cameras = [];

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
    var arguments = ModalRoute.of(context)!.settings.arguments as List;

    bool shuffle = arguments[1] as bool;
    if (cameras.isEmpty) {
      cameras = arguments[0] as List<Camera>;
      if (shuffle) {
        cameras.shuffle();
      }
    }
    timer ??= Timer.periodic(
      Duration(
          seconds: shuffle
              ? 6
              : cameras.first.city == City.quebec
                  ? 30
                  : 3),
      (t) => setState(() {}),
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: shuffle ? 1 : cameras.length,
              itemBuilder: (context, index) {
                Camera camera =
                    cameras[shuffle ? Random().nextInt(cameras.length) : index];
                if (camera.city == City.vancouver) {
                  return FutureBuilder<List<String>>(
                    future: DownloadService.getHtmlImages(camera.url),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.requireData.map((url) {
                            return CameraWidget(camera, otherUrl: url);
                          }).toList(),
                        );
                      } else if (snapshot.hasError) {
                        return CameraWidget(camera);
                      }
                      return const SizedBox();
                    },
                  );
                } //
                else if (camera.city == City.quebec) {
                  VideoPlayerController vpc =
                      VideoPlayerController.networkUrl(Uri.parse(camera.url));
                  return CameraVideoWidget(camera: camera, controller: vpc);
                }
                return CameraWidget(camera);
              },
            ),
            Container(
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
            ),
          ],
        ),
      ),
    );
  }
}

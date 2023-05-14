import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';

import '../entities/camera.dart';
import '../widgets/camera_widget.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/cameraPage';

  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraState();
}

class _CameraState extends State<CameraPage> with WidgetsBindingObserver {
  Timer? timer;

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
    List<Camera> cameras = arguments[0] as List<Camera>;
    bool shuffle = arguments[1] as bool;
    timer ??= Timer.periodic(
      Duration(seconds: shuffle ? 6 : 3),
      (t) => setState(() {}),
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: shuffle ? 1 : cameras.length,
              itemBuilder: (context, index) {
                return CameraWidget(
                  cameras[shuffle ? Random().nextInt(cameras.length) : index],
                );
              },
            ),
            Container(
              color: Colors.white54,
              margin: const EdgeInsets.all(5),
              child: const BackButton(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../entities/camera.dart';
import '../widgets/camera_widget.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/cameraPage';

  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraState();
}

class _CameraState extends State<CameraPage> {
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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

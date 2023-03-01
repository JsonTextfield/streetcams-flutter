import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../entities/camera.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/cameraPage';

  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraState();
}

class _CameraState extends State<CameraPage> {
  List<Camera> cameras = [];
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var arguments = ModalRoute.of(context)!.settings.arguments as List;
    cameras = arguments[0] as List<Camera>;
    final bool shuffle = arguments[1] as bool;
    timer ??= Timer.periodic(
      const Duration(seconds: 6),
      (t) => setState(() {}),
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: shuffle ? 1 : cameras.length,
              itemBuilder: (context, index) {
                var camera =
                    cameras[shuffle ? Random().nextInt(cameras.length) : index];
                return CameraWidget(camera: camera);
              },
            ),
            Container(
              margin: const EdgeInsets.all(5),
              child: FloatingActionButton(
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(128, 255, 255, 255),
                onPressed: Navigator.of(context).pop,
                tooltip: AppLocalizations.of(context)!.back,
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraWidget extends StatelessWidget {
  // Widget for an individual camera feed
  final Camera camera;

  const CameraWidget({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    int time = DateTime.now().millisecondsSinceEpoch;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height -
            MediaQueryData.fromWindow(window).padding.top,
      ),
      child: Stack(
        children: [
          Image.network(
            'https://traffic.ottawa.ca/beta/camera?id=${camera.num}&timems=$time',
            semanticLabel: camera.name,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
            gaplessPlayback: true,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: const Color.fromARGB(128, 0, 0, 0),
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

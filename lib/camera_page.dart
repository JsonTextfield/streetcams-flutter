import 'dart:async';

import 'package:flutter/material.dart';

import 'entities/camera.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/cameraPage';

  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraState();
}

class _CameraState extends State<CameraPage> {
  List<Camera> cameras = [];

  @override
  Widget build(BuildContext context) {
    cameras = ModalRoute.of(context)!.settings.arguments as List<Camera>;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: cameras.map((e) => CameraImage(camera: e)).toList(),
      ),
    );
  }
}

class CameraImage extends StatefulWidget {
  const CameraImage({Key? key, required this.camera}) : super(key: key);

  final Camera camera;

  @override
  State<CameraImage> createState() => _CameraImageState();
}

class _CameraImageState extends State<CameraImage> {
  Timer? timer;
  var networkImage = const NetworkImage('');

  @override
  void initState() {
    initializeCameraImage();
    timer = Timer.periodic(const Duration(seconds: 6), (t) {
      setState(() {
        initializeCameraImage();
      });
    });
    super.initState();
  }

  void initializeCameraImage() {
    networkImage = NetworkImage(
        'https://traffic.ottawa.ca/beta/camera?id=${widget.camera.num}&timems=${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: Image(
            image: networkImage,
            semanticLabel: widget.camera.getName(),
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color.fromARGB(128, 0, 0, 0),
              child: Text(
                widget.camera.getName(),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

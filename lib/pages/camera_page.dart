import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../entities/camera.dart';

class CameraPage extends StatefulWidget {
  static const routeName = '/cameraPage';

  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraState();
}

class _CameraState extends State<CameraPage> {
  List<Camera> cameras = [];
  var shuffle = false;
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
    shuffle = arguments[1] as bool;
    if (shuffle && timer == null) {
      timer = Timer.periodic(const Duration(seconds: 6), (timer) {
        setState(() {});
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: getCameraImages(),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              color: const Color.fromARGB(128, 255, 255, 255),
              child: IconButton(
                color: Colors.black,
                padding: const EdgeInsets.all(10),
                onPressed: Navigator.of(context).pop,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CameraImage> getCameraImages() {
    if (shuffle) {
      var camera = cameras[Random().nextInt(cameras.length)];
      return [CameraImage(camera: camera, shuffle: true)];
    }
    return cameras.map((e) => CameraImage(camera: e)).toList();
  }
}

class CameraImage extends StatefulWidget {
  // Widget for an individual camera feed
  const CameraImage({Key? key, required this.camera, this.shuffle = false})
      : super(key: key);

  final Camera camera;
  final bool shuffle;

  @override
  State<CameraImage> createState() => _CameraImageState();
}

class _CameraImageState extends State<CameraImage> {
  Timer? timer;
  MemoryImage? image;
  String url = '';

  Future<void> initializeCameraImage() async {
    await http
        .get(Uri.parse(url))
        .then((resp) => {image = MemoryImage(resp.bodyBytes)});
  }

  @override
  Widget build(BuildContext context) {
    url =
        'https://traffic.ottawa.ca/beta/camera?id=${widget.camera.num}&timems=${DateTime.now().millisecondsSinceEpoch}';
    if (!widget.shuffle && timer == null) {
      timer = Timer.periodic(const Duration(seconds: 6), (t) {
        initializeCameraImage().then((value) => setState(() {}));
      });
    }

    ImageProvider imageProvider;
    if (image != null && !widget.shuffle) {
      imageProvider = image!;
    } else {
      imageProvider = NetworkImage(url);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: Stack(
        children: [
          Image(
            image: imageProvider,
            semanticLabel: widget.camera.name,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: const Color.fromARGB(128, 0, 0, 0),
                child: Text(
                  widget.camera.name,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

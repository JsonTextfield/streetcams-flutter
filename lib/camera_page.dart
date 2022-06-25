import 'package:flutter/material.dart';

import 'entities/camera.dart';

class CameraPage extends StatelessWidget {
  static const routeName = '/cameraPage';
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {

    var cameras = ModalRoute.of(context)!.settings.arguments as List<Camera>;
    var camera = cameras[0];
    var url =
        'https://traffic.ottawa.ca/beta/camera?id=${camera.num}&timems=${DateTime.now().millisecond}';
    return Scaffold(
      appBar: AppBar(
        title: Text(camera.getName()),
      ),
      body: Center(
        child: Image.network(
          url,
          semanticLabel: camera.getName(),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/camera_bloc.dart';
import '../entities/camera.dart';

class CameraGalleryWidget extends StatelessWidget {
  final Camera camera;

  const CameraGalleryWidget(this.camera, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            camera.url,
            gaplessPlayback: true,
            fit: BoxFit.cover,
            errorBuilder: (context, exception, stackTrace) {
              return Container(
                color: Colors.grey,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                child: const Text(
                  'Image\nunavailable\n😢',
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          Visibility(
            visible: context
                .read<CameraBloc>()
                .state
                .selectedCameras
                .contains(camera),
            child: Container(
              color: const Color(0x7722AAFF),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/camera_bloc.dart';
import '../../entities/camera.dart';

class LoadingGalleryWidget extends StatelessWidget {
  final Camera camera;

  const LoadingGalleryWidget(this.camera, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.grey),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.all(2),
              color: Colors.black54,
              child: Text(
                camera.name,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Visibility(
            visible: camera.isFavourite,
            child: const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.star_rounded, color: Colors.yellow),
            ),
          ),
          Visibility(
            visible: context
                .read<CameraBloc>()
                .state
                .selectedCameras
                .contains(camera),
            child: Container(color: const Color(0x7722AAFF)),
          ),
        ],
      ),
    );
  }
}

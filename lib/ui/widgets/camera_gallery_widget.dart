import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/camera_bloc.dart';
import '../../constants.dart';
import '../../entities/camera.dart';
import '../../entities/city.dart';

class CameraGalleryWidget extends StatelessWidget {
  final Camera camera;
  final String otherUrl;
  final bool isLoaded;

  const CameraGalleryWidget(
    this.camera, {
    super.key,
    this.otherUrl = '',
    this.isLoaded = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
          if (isLoaded)
            CachedNetworkImage(
              imageUrl: camera.city == City.vancouver ? otherUrl : camera.url,
              fit: BoxFit.cover,
              errorWidget: (context, exception, stackTrace) {
                return const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey),
                  child: Center(child: Icon(Icons.videocam_off_rounded)),
                );
              },
            ),
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
          if (camera.isFavourite)
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.star_rounded, color: Colors.yellow),
            ),
          if (context.read<CameraBloc>().state.selectedCameras.contains(camera))
            const DecoratedBox(
              decoration: BoxDecoration(color: Constants.selectedColour),
            ),
        ],
      ),
    );
  }
}

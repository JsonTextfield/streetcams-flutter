import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/ui/widgets/camera_error_widget.dart';

import '../../blocs/camera_bloc.dart';
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          if (camera.city == City.quebec)
            FutureBuilder(
              future: DownloadService.getVideoFrame(camera.preview),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    frameBuilder: (BuildContext context, Widget child,
                        int? frame, bool wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) {
                        return child;
                      }
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                  );
                }
                if (snapshot.hasError) {
                  return const CameraErrorWidget();
                }
                return const SizedBox();
              },
            ),
          if (isLoaded && camera.city != City.quebec)
            CachedNetworkImage(
              imageUrl:
                  camera.city == City.vancouver ? otherUrl : camera.preview,
              fit: BoxFit.cover,
              errorWidget: (context, exception, stackTrace) {
                return const CameraErrorWidget();
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
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(0x88),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:streetcams_flutter/services/download_service.dart';

import '../../entities/camera.dart';
import '../../entities/city.dart';
import 'camera_gallery_widget.dart';

class CameraGalleryView extends StatelessWidget {
  final ScrollController? scrollController;
  final List<Camera> cameras;
  final void Function(Camera)? onItemClick;
  final void Function(Camera)? onItemLongClick;

  const CameraGalleryView({
    super.key,
    required this.cameras,
    this.scrollController,
    this.onItemClick,
    this.onItemLongClick,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('building camera gridview');
    return RawScrollbar(
      controller: scrollController,
      thumbColor: Theme.of(context).colorScheme.primary,
      radius: const Radius.circular(10),
      thickness: 10,
      interactive: true,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(5),
        itemCount: cameras.length + 1,
        itemBuilder: (context, index) {
          if (index == cameras.length) {
            return ListTile(
              title: Center(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    context.translation
                        .cameras(cameras.length)
                        .replaceFirst(' ', '\n'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          Camera camera = cameras[index];
          if (camera.city == City.vancouver) {
            return FutureBuilder<List<String>>(
              future: DownloadService.getHtmlImages(camera.url),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onLongPress: () => onItemLongClick?.call(camera),
                    onTap: () => onItemClick?.call(camera),
                    child: CameraGalleryWidget(
                      camera,
                      otherUrl: snapshot.requireData.first,
                    ),
                  );
                }
                return GestureDetector(
                  onLongPress: () => onItemLongClick?.call(camera),
                  onTap: () => onItemClick?.call(camera),
                  child: CameraGalleryWidget(camera, isLoaded: false),
                );
              },
            );
          }
          return GestureDetector(
            onLongPress: () => onItemLongClick?.call(camera),
            onTap: () => onItemClick?.call(camera),
            child: CameraGalleryWidget(camera),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              max(3, (MediaQuery.sizeOf(context).width ~/ 100).clamp(3, 9)),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }
}

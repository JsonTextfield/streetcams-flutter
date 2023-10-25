import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:streetcams_flutter/services/download_service.dart';
import 'package:streetcams_flutter/ui/widgets/loading_gallery_widget.dart';

import '../../entities/camera.dart';
import '../../entities/city.dart';
import 'camera_gallery_widget.dart';

class CameraGalleryView extends StatelessWidget {
  final List<Camera> cameras;
  final scrollController = ScrollController();
  final void Function(Camera)? onItemClick;
  final void Function(Camera)? onItemLongClick;

  CameraGalleryView({
    super.key,
    required this.cameras,
    this.onItemClick,
    this.onItemLongClick,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: scrollController,
      thumbColor: const Color(0xDD22AAFF),
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
                child: Text(
                  AppLocalizations.of(context)!.cameras(cameras.length),
                  textAlign: TextAlign.center,
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
                      otherUrl: snapshot.requireData[
                          Random().nextInt(snapshot.requireData.length)],
                    ),
                  );
                }
                return GestureDetector(
                  onLongPress: () => onItemLongClick?.call(camera),
                  onTap: () => onItemClick?.call(camera),
                  child: LoadingGalleryWidget(camera),
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

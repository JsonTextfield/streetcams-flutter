import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../entities/camera.dart';
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
          return GestureDetector(
            onLongPress: () => onItemLongClick?.call(cameras[index]),
            onTap: () => onItemClick?.call(cameras[index]),
            child: CameraGalleryWidget(cameras[index]),
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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:streetcams_flutter/widgets/camera_gallery_widget.dart';

import '../blocs/camera_bloc.dart';
import '../entities/camera.dart';
import '../pages/camera_page.dart';

class CameraGalleryView extends StatelessWidget {
  final List<Camera> cameras;

  const CameraGalleryView(this.cameras, {super.key});

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: const Color(0xDD22AAFF),
      radius: const Radius.circular(10),
      thickness: 10,
      interactive: true,
      child: GridView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: cameras.length + 1,
        itemBuilder: (context, index) {
          if (index == cameras.length) {
            return ListTile(
              title: Center(
                child: Text(
                  AppLocalizations.of(context)!.cameras(cameras.length),
                ),
              ),
            );
          }
          return GestureDetector(
            onLongPress: () {
              context
                  .read<CameraBloc>()
                  .add(SelectCamera(camera: cameras[index]));
            },
            onTap: () {
              if (context.read<CameraBloc>().state.selectedCameras.isEmpty) {
                Navigator.pushNamed(
                  context,
                  CameraPage.routeName,
                  arguments: [
                    [cameras[index]],
                    false,
                  ],
                );
              } else {
                context
                    .read<CameraBloc>()
                    .add(SelectCamera(camera: cameras[index]));
              }
            },
            child: CameraGalleryWidget(cameras[index]),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: max(3, MediaQuery.of(context).size.width ~/ 100),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      ),
    );
  }
}

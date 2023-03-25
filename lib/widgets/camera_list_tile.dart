import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/camera_bloc.dart';
import '../constants.dart';
import '../entities/camera.dart';
import '../pages/camera_page.dart';

class CameraListTile extends StatelessWidget {
  final Camera camera;
  final void Function() tapped;

  const CameraListTile({
    super.key,
    required this.camera,
    required this.tapped,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        tapped() {
          if (state.selectedCameras.isNotEmpty) {
            context.read<CameraBloc>().add(SelectCamera(camera: camera));
          } else {
            Navigator.pushNamed(
              context,
              CameraPage.routeName,
              arguments: [
                [camera],
                false,
              ],
            );
          }
        }

        return ListTile(
            selected: state.selectedCameras.contains(camera),
            selectedTileColor: Constants.accentColour,
            selectedColor: Colors.white,
            dense: true,
            title: Text(camera.name, style: const TextStyle(fontSize: 16)),
            subtitle: Text(camera.neighbourhood),
            trailing: IconButton(
              icon: Icon(camera.isFavourite ? Icons.star : Icons.star_border),
              color: camera.isFavourite ? Colors.yellow : null,
              onPressed: () {
                camera.isFavourite = !camera.isFavourite;
                context.read<CameraBloc>().updateCamera(camera);
              },
            ),
            onTap: tapped,
            onLongPress: () {
              context.read<CameraBloc>().add(SelectCamera(camera: camera));
            },
        );
      },
    );
  }
}

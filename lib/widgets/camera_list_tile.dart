import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/camera_bloc.dart';
import '../constants.dart';
import '../entities/camera.dart';

class CameraListTile extends StatelessWidget {
  final Camera camera;
  final void Function()? tapped;

  const CameraListTile({
    super.key,
    required this.camera,
    this.tapped,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        var selectedCameras = state.selectedCameras;

        tapped() {
          if (selectedCameras.isNotEmpty) {
            context.read<CameraBloc>().add(SelectCamera(camera: camera));
          } else {
            this.tapped?.call();
          }
        }

        longPressed() {
          context.read<CameraBloc>().add(SelectCamera(camera: camera));
        }

        favouriteTapped() {
          context.read<CameraBloc>().favouriteCamera(camera);
        }

        dismissed() {
          context.read<CameraBloc>().hideCamera(camera);
        }

        return Dismissible(
          key: Key(camera.sortableName),
          child: ListTile(
            selected: selectedCameras.contains(camera),
            selectedTileColor: Constants.accentColour,
            selectedColor: Colors.white,
            dense: true,
            title: Text(camera.name, style: const TextStyle(fontSize: 16)),
            subtitle: Text(camera.neighbourhood),
            trailing: IconButton(
              icon: Icon(camera.isFavourite ? Icons.star : Icons.star_border),
              color: camera.isFavourite ? Colors.yellow : null,
              onPressed: favouriteTapped,
            ),
            onTap: tapped,
            onLongPress: longPressed,
          ),
          onDismissed: (direction) => dismissed(),
        );
      },
    );
  }
}

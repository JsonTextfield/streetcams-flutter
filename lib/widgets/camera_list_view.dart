import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../blocs/camera_bloc.dart';
import '../constants.dart';
import '../entities/camera.dart';
import '../pages/camera_page.dart';

class CameraListView extends StatelessWidget {
  final ItemScrollController? itemScrollController;
  final List<Camera> cameras;
  final void Function(Camera)? onTapped;

  const CameraListView({
    super.key,
    required this.cameras,
    this.onTapped,
    this.itemScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        debugPrint('building camera listview');
        return ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
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

            Camera camera = cameras[index];

            hide() {
              camera.isVisible = !camera.isVisible;
              if (state.displayedCameras.contains(camera)) {
                state.displayedCameras.remove(camera);
              } else {
                state.displayedCameras.insert(index, camera);
              }
              context.read<CameraBloc>().updateCamera(camera);
            }

            dismissed() {
              hide();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  '${camera.name} ${camera.isVisible ? 'unhidden' : 'hidden'}',
                ),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: hide,
                ),
              ));
            }

            return Dismissible(
              key: UniqueKey(),
              onDismissed: (direction) => dismissed(),
              background: Container(
                color: Constants.accentColour,
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    camera.isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                ),
              ),
              secondaryBackground: Container(
                color: Constants.accentColour,
                padding: const EdgeInsets.only(right: 20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    camera.isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                ),
              ),
              child: ListTile(
                selected: state.selectedCameras.contains(camera),
                selectedTileColor: Constants.accentColour,
                selectedColor: Colors.white,
                dense: true,
                contentPadding: const EdgeInsets.only(left: 5),
                minLeadingWidth: 0,
                visualDensity: const VisualDensity(vertical: -2),
                title: Text(camera.name, style: const TextStyle(fontSize: 16)),
                subtitle: Text(camera.neighbourhood),
                leading: state.sortingMethod == SortingMethod.distance
                    ? Text(
                        camera.distance,
                        textAlign: TextAlign.center,
                      )
                    : null,
                trailing: IconButton(
                  icon:
                      Icon(camera.isFavourite ? Icons.star : Icons.star_border),
                  color: camera.isFavourite ? Colors.yellow : null,
                  onPressed: () {
                    camera.isFavourite = !camera.isFavourite;
                    context.read<CameraBloc>().updateCamera(camera);
                  },
                ),
                onTap: () {
                  if (state.selectedCameras.isEmpty) {
                    Navigator.pushNamed(
                      context,
                      CameraPage.routeName,
                      arguments: [
                        [camera],
                        false,
                      ],
                    );
                  } else {
                    context
                        .read<CameraBloc>()
                        .add(SelectCamera(camera: camera));
                  }
                },
                onLongPress: () {
                  context.read<CameraBloc>().add(SelectCamera(camera: camera));
                },
              ),
            );
          },
        );
      },
    );
  }
}

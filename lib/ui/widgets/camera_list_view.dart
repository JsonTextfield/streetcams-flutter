import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../blocs/camera_bloc.dart';
import '../../constants.dart';
import '../../entities/camera.dart';
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
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            Camera cam = cameras[index];

            hide() {
              cam.isVisible = !cam.isVisible;
              if (state.displayedCameras.contains(cam)) {
                state.displayedCameras.remove(cam);
              } else {
                state.displayedCameras.insert(index, cam);
              }
              context.read<CameraBloc>().updateCamera(cam);
            }

            dismissed() {
              hide();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  '${cam.name} ${cam.isVisible ? 'unhidden' : 'hidden'}',
                ),
                action: SnackBarAction(
                  label: AppLocalizations.of(context)!.undo,
                  onPressed: hide,
                ),
              ));
            }

            return Dismissible(
              key: UniqueKey(),
              direction: state.filterMode == FilterMode.favourite
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              onDismissed: (direction) => dismissed(),
              background: DismissibleBackground(
                icon: cam.isVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                alignment: Alignment.centerLeft,
              ),
              secondaryBackground: DismissibleBackground(
                icon: cam.isVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                alignment: Alignment.centerRight,
              ),
              child: ListTile(
                selected: state.selectedCameras.contains(cam),
                selectedTileColor: Constants.accentColour,
                selectedColor: Colors.white,
                dense: true,
                contentPadding: const EdgeInsets.only(left: 5),
                minLeadingWidth: 0,
                visualDensity: const VisualDensity(vertical: -2),
                title: Text(cam.name, style: const TextStyle(fontSize: 16)),
                subtitle: Text(cam.neighbourhood),
                leading: state.sortingMethod == SortingMethod.distance
                    ? Text(cam.distance, textAlign: TextAlign.center)
                    : null,
                trailing: IconButton(
                  icon: Icon(cam.isFavourite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded),
                  color: cam.isFavourite ? Colors.yellow : null,
                  onPressed: () {
                    cam.isFavourite = !cam.isFavourite;
                    context.read<CameraBloc>().updateCamera(cam);
                  },
                ),
                onTap: () {
                  if (state.selectedCameras.isEmpty) {
                    Navigator.pushNamed(
                      context,
                      CameraPage.routeName,
                      arguments: [
                        [cam],
                        false,
                      ],
                    );
                  } else {
                    context.read<CameraBloc>().add(SelectCamera(camera: cam));
                  }
                },
                onLongPress: () {
                  context.read<CameraBloc>().add(SelectCamera(camera: cam));
                },
              ),
            );
          },
        );
      },
    );
  }
}

class DismissibleBackground extends StatelessWidget {
  final IconData icon;
  final Alignment alignment;

  const DismissibleBackground({
    super.key,
    required this.icon,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.accentColour,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      child: Icon(icon, color: Colors.white),
    );
  }
}

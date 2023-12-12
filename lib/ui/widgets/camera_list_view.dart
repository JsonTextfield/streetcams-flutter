import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:streetcams_flutter/l10n/translation.dart';

import '../../blocs/camera_bloc.dart';
import '../../constants.dart';
import '../../entities/camera.dart';

class CameraListView extends StatelessWidget {
  final ItemScrollController? itemScrollController;
  final List<Camera> cameras;
  final void Function(Camera)? onItemClick;
  final void Function(Camera)? onItemLongClick;

  const CameraListView({
    super.key,
    required this.cameras,
    this.onItemClick,
    this.itemScrollController,
    this.onItemLongClick,
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
                    context.translation.cameras(cameras.length),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            Camera cam = cameras[index];

            hide() {
              if (state.displayedCameras.contains(cam)) {
                state.displayedCameras.remove(cam);
              } else {
                state.displayedCameras.insert(index, cam);
              }
              context.read<CameraBloc>().add(HideCameras([cam]));
            }

            dismissed() {
              hide();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  '${cam.name} ${cam.isVisible ? 'unhidden' : 'hidden'}',
                ),
                action: SnackBarAction(
                  label: context.translation.undo,
                  onPressed: hide,
                ),
              ));
            }

            String title = cam.isVisible
                ? context.translation.hide
                : context.translation.unhide;
            IconData icon = cam.isVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded;
            return Dismissible(
              key: UniqueKey(),
              direction: state.filterMode == FilterMode.favourite
                  ? DismissDirection.none
                  : DismissDirection.horizontal,
              onDismissed: (direction) => dismissed(),
              background: DismissibleBackground(
                title: title,
                icon: icon,
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
                subtitle: cam.neighbourhood.isNotEmpty
                    ? Text(cam.neighbourhood)
                    : null,
                leading: state.sortMode == SortMode.distance
                    ? Text(cam.distanceString, textAlign: TextAlign.center)
                    : null,
                trailing: IconButton(
                  icon: Icon(cam.isFavourite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded),
                  color: cam.isFavourite ? Colors.yellow : null,
                  onPressed: () {
                    context.read<CameraBloc>().add(FavouriteCameras([cam]));
                  },
                ),
                onTap: () => onItemClick?.call(cameras[index]),
                onLongPress: () => onItemLongClick?.call(cameras[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class DismissibleBackground extends StatelessWidget {
  final String title;
  final IconData icon;

  const DismissibleBackground({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.accentColour,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          Expanded(child: Text(title, textAlign: TextAlign.center)),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}

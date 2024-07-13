import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/l10n/translation.dart';

class CameraListView extends StatelessWidget {
  final ItemScrollController? itemScrollController;
  final List<Camera> cameras;
  final void Function(Camera)? onItemClick;
  final void Function(Camera)? onItemLongClick;

  const CameraListView({
    super.key,
    required this.cameras,
    this.itemScrollController,
    this.onItemClick,
    this.onItemLongClick,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('building camera listview');
    CameraState state = context.read<CameraBloc>().state;
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
          context.read<CameraBloc>().add(HideCameras([cam]));
        }

        dismissed() {
          hide();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              cam.isVisible
                  ? context.translation.hiddenCamera(cam.name)
                  : context.translation.unhiddenCamera(cam.name),
            ),
            action: SnackBarAction(
              label: context.translation.undo,
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
          background: DismissibleBackground(cam.isVisible),
          child: ListTile(
            selected: state.selectedCameras.contains(cam),
            selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
            selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
            title: Text(cam.name, style: const TextStyle(fontSize: 16)),
            subtitle:
                cam.neighbourhood.isNotEmpty ? Text(cam.neighbourhood) : null,
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
  }
}

class DismissibleBackground extends StatelessWidget {
  final bool isVisible;

  const DismissibleBackground(this.isVisible, {super.key});

  @override
  Widget build(BuildContext context) {
    Icon icon = Icon(
      isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      color: Theme.of(context).colorScheme.onSecondaryContainer,
    );
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Center(
        child: ListTile(
          leading: icon,
          trailing: icon,
          title: Text(
            isVisible ? context.translation.hide : context.translation.unhide,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

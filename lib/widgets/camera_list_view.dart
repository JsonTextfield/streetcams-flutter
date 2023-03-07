import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../blocs/camera_bloc.dart';
import '../entities/camera.dart';
import 'camera_list_tile.dart';
import 'section_index.dart';

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
    debugPrint('building listview');
    return BlocBuilder<CameraBloc, CameraState>(builder: (context, state) {
      return Row(children: [
        if (state.filterMode == FilterMode.visible &&
            state.sortingMethod == SortMode.name)
          Flexible(
            flex: 0,
            child: SectionIndex(
              data: cameras.map((cam) => cam.sortableName).toList(),
              callback: _moveToListPosition,
            ),
          ),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemCount: cameras.length + 1,
            itemBuilder: (context, i) {
              if (i == cameras.length) {
                return ListTile(
                  title: Center(
                    child: Text(
                      AppLocalizations.of(context)!.cameras(cameras.length),
                    ),
                  ),
                );
              }
              return CameraListTile(
                camera: cameras[i],
                tapped: () => onTapped?.call(cameras[i]),
              );
            },
          ),
        ),
      ]);
    });
  }

  void _moveToListPosition(int index) {
    itemScrollController?.jumpTo(index: index);
  }
}

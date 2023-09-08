import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../blocs/camera_bloc.dart';
import 'radio_menu_item.dart';

class SortCamerasMenu extends StatelessWidget {
  const SortCamerasMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void sortCameras(SortMode sortMode) {
          context.read<CameraBloc>().add(SortCameras(sortMode: sortMode));
        }

        return PopupMenuButton<SortMode>(
          position: PopupMenuPosition.under,
          icon: const Icon(Icons.sort_rounded),
          tooltip: AppLocalizations.of(context)!.sort,
          itemBuilder: (context) => [
            RadioMenuItem<SortMode>(
              value: SortMode.name,
              text: AppLocalizations.of(context)!.sortName,
              groupValue: state.sortMode,
              onChanged: (_) {},
            ),
            RadioMenuItem<SortMode>(
              value: SortMode.distance,
              text: AppLocalizations.of(context)!.sortDistance,
              groupValue: state.sortMode,
              onChanged: (_) {},
            ),
            RadioMenuItem<SortMode>(
              value: SortMode.neighbourhood,
              text: AppLocalizations.of(context)!.sortNeighbourhood,
              groupValue: state.sortMode,
              onChanged: (_) {},
            ),
          ],
          onSelected: sortCameras,
        );

        return MenuAnchor(
          builder: (context, menu, child) {
            return IconButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: const Icon(Icons.sort_rounded),
              tooltip: AppLocalizations.of(context)!.sort,
            );
          },
          menuChildren: [
            RadioMenuButton<SortMode>(
              value: SortMode.name,
              groupValue: state.sortMode,
              onChanged: (_) => sortCameras(SortMode.name),
              child: Text(AppLocalizations.of(context)!.sortName),
            ),
            RadioMenuButton<SortMode>(
              value: SortMode.distance,
              groupValue: state.sortMode,
              onChanged: (_) => sortCameras(SortMode.distance),
              child: Text(AppLocalizations.of(context)!.sortDistance),
            ),
            RadioMenuButton<SortMode>(
              value: SortMode.neighbourhood,
              groupValue: state.sortMode,
              onChanged: (_) => sortCameras(SortMode.neighbourhood),
              child: Text(AppLocalizations.of(context)!.sortNeighbourhood),
            ),
          ],
        );
      },
    );
  }
}

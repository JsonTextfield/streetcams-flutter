import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../blocs/camera_bloc.dart';

class SortCamerasMenu extends StatelessWidget {
  const SortCamerasMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void sortCameras(SortingMethod sortMode) {
          context.read<CameraBloc>().add(SortCameras(sortingMethod: sortMode));
        }

        return MenuAnchor(
          builder: (context, menu, child) {
            return IconButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: const Icon(Icons.sort),
              tooltip: AppLocalizations.of(context)!.sort,
            );
          },
          menuChildren: [
            RadioMenuButton<SortingMethod>(
              value: SortingMethod.name,
              groupValue: state.sortingMethod,
              onChanged: (_) => sortCameras(SortingMethod.name),
              child: Text(AppLocalizations.of(context)!.sortName),
            ),
            RadioMenuButton<SortingMethod>(
              value: SortingMethod.distance,
              groupValue: state.sortingMethod,
              onChanged: (_) => sortCameras(SortingMethod.distance),
              child: Text(AppLocalizations.of(context)!.sortDistance),
            ),
            RadioMenuButton<SortingMethod>(
              value: SortingMethod.neighbourhood,
              groupValue: state.sortingMethod,
              onChanged: (_) => sortCameras(SortingMethod.neighbourhood),
              child: Text(
                AppLocalizations.of(context)!.sortNeighbourhood,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        );
      },
    );
  }
}

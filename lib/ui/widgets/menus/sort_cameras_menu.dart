import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../blocs/camera_bloc.dart';

class SortCamerasMenu extends StatelessWidget {
  const SortCamerasMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void sortCameras(SortMode sortMode) {
          context.read<CameraBloc>().add(SortCameras(sortMode: sortMode));
        }

        return MenuAnchor(
          builder: (context, menu, child) {
            return IconButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: const Icon(Icons.sort_rounded),
              tooltip: AppLocalizations.of(context)!.sort,
            );
          },
          menuChildren: SortMode.values.map((sortMode) {
            return RadioMenuButton<SortMode>(
              value: sortMode,
              groupValue: state.sortMode,
              onChanged: (_) => sortCameras(sortMode),
              child: Text(
                AppLocalizations.of(context)!.getSortMode(sortMode.name),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

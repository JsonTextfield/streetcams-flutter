import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../blocs/camera_bloc.dart';

class ViewModeMenu extends StatelessWidget {
  const ViewModeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void changeViewMode(ViewMode viewMode) {
          context.read<CameraBloc>().add(ChangeViewMode(viewMode: viewMode));
        }

        return MenuAnchor(
          builder: (context, menu, child) {
            return IconButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: Icon(getIcon(state.viewMode)),
              tooltip: AppLocalizations.of(context)!
                  .getViewMode(state.viewMode.name),
            );
          },
          menuChildren: ViewMode.values.where((ViewMode viewMode) {
            return viewMode != ViewMode.map ||
                defaultTargetPlatform != TargetPlatform.windows ||
                kIsWeb;
          }).map((ViewMode viewMode) {
            return RadioMenuButton<ViewMode>(
              value: viewMode,
              groupValue: state.viewMode,
              onChanged: (_) => changeViewMode(viewMode),
              child: Text(
                AppLocalizations.of(context)!.getViewMode(viewMode.name),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData getIcon(ViewMode viewMode) {
    return switch (viewMode) {
      ViewMode.map => Icons.place,
      ViewMode.gallery => Icons.grid_view_rounded,
      ViewMode.list => Icons.list
    };
  }
}

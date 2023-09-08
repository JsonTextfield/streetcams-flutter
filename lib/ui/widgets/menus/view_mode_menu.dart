import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:streetcams_flutter/ui/widgets/menus/radio_menu_item.dart';

import '../../../blocs/camera_bloc.dart';

class ViewModeMenu extends StatelessWidget {
  const ViewModeMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void changeViewMode(ViewMode viewMode) {
          context.read<CameraBloc>().add(ReloadCameras(viewMode: viewMode));
        }

        return PopupMenuButton<ViewMode>(
          position: PopupMenuPosition.under,
          icon: Icon(getIcon(state.viewMode)),
          tooltip: getTooltip(context, state.viewMode),
          itemBuilder: (context) => [
            RadioMenuItem<ViewMode>(
              value: ViewMode.list,
              text: AppLocalizations.of(context)!.list,
              groupValue: state.viewMode,
              onChanged: (_) {},
            ),
            RadioMenuItem<ViewMode>(
              value: ViewMode.map,
              text: AppLocalizations.of(context)!.map,
              groupValue: state.viewMode,
              onChanged: (_) {},
            ),
            RadioMenuItem<ViewMode>(
              value: ViewMode.gallery,
              text: AppLocalizations.of(context)!.gallery,
              groupValue: state.viewMode,
              onChanged: (_) {},
            ),
          ],
          onSelected: changeViewMode,
        );

        return MenuAnchor(
          builder: (context, menu, child) {
            return IconButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: Icon(getIcon(state.viewMode)),
              tooltip: getTooltip(context, state.viewMode),
            );
          },
          menuChildren: <RadioMenuButton<ViewMode>>[
            RadioMenuButton<ViewMode>(
              value: ViewMode.list,
              groupValue: state.viewMode,
              onChanged: (_) => changeViewMode(ViewMode.list),
              child: Text(AppLocalizations.of(context)!.list),
            ),
            if (defaultTargetPlatform != TargetPlatform.windows || kIsWeb)
              RadioMenuButton<ViewMode>(
                value: ViewMode.map,
                groupValue: state.viewMode,
                onChanged: (_) => changeViewMode(ViewMode.map),
                child: Text(AppLocalizations.of(context)!.map),
              ),
            RadioMenuButton<ViewMode>(
              value: ViewMode.gallery,
              groupValue: state.viewMode,
              onChanged: (_) => changeViewMode(ViewMode.gallery),
              child: Text(AppLocalizations.of(context)!.gallery),
            ),
          ],
        );
      },
    );
  }

  String getTooltip(BuildContext context, ViewMode viewMode) {
    return switch (viewMode) {
      ViewMode.map => AppLocalizations.of(context)!.map,
      ViewMode.gallery => AppLocalizations.of(context)!.gallery,
      ViewMode.list => AppLocalizations.of(context)!.list
    };
  }

  IconData getIcon(ViewMode viewMode) {
    return switch (viewMode) {
      ViewMode.map => Icons.place,
      ViewMode.gallery => Icons.grid_view_rounded,
      ViewMode.list => Icons.list
    };
  }
}

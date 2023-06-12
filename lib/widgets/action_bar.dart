import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streetcams_flutter/widgets/change_city_menu.dart';
import 'package:streetcams_flutter/widgets/sort_cameras_menu.dart';
import 'package:streetcams_flutter/widgets/view_mode_menu.dart';

import '../blocs/camera_bloc.dart';
import '../entities/camera.dart';
import '../pages/camera_page.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building action bar');
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        List<Camera> selectedCameras = state.selectedCameras;
        String getFavouriteTooltip() {
          if (selectedCameras.isEmpty) {
            return AppLocalizations.of(context)!.favourites;
          } else if (selectedCameras.every((camera) => camera.isFavourite)) {
            return AppLocalizations.of(context)!.unfavourite;
          }
          return AppLocalizations.of(context)!.favourite;
        }

        String getHiddenTooltip() {
          if (selectedCameras.isEmpty) {
            return AppLocalizations.of(context)!.hidden;
          } else if (selectedCameras.any((camera) => camera.isVisible)) {
            return AppLocalizations.of(context)!.hide;
          }
          return AppLocalizations.of(context)!.unhide;
        }

        IconData getFavouriteIcon() {
          if (selectedCameras.isEmpty ||
              selectedCameras.any((c) => !c.isFavourite)) {
            return Icons.star;
          }
          return Icons.star_border;
        }

        IconData getHiddenIcon() {
          if (selectedCameras.isEmpty ||
              selectedCameras.any((c) => c.isVisible)) {
            return Icons.visibility_off;
          }
          return Icons.visibility;
        }

        void showRandomCamera() {
          List<Camera> visibleCameras = state.visibleCameras;
          if (visibleCameras.isNotEmpty) {
            showCameras(
              context,
              [visibleCameras[Random().nextInt(visibleCameras.length)]],
            );
          }
        }

        void filterCameras(FilterMode filterMode) {
          context.read<CameraBloc>().add(FilterCamera(filterMode: filterMode));
        }

        void searchCameras(SearchMode searchMode) {
          context.read<CameraBloc>().add(SearchCameras(searchMode: searchMode));
        }

        void favouriteOptionClicked() {
          if (state.selectedCameras.isEmpty) {
            filterCameras(FilterMode.favourite);
          } else {
            context.read<CameraBloc>().favouriteSelectedCameras();
          }
        }

        void hideOptionClicked() {
          if (state.selectedCameras.isEmpty) {
            filterCameras(FilterMode.hidden);
          } else {
            context.read<CameraBloc>().hideSelectedCameras();
          }
        }

        var clear = Visibility(
          visible: selectedCameras.isNotEmpty,
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.clear,
            onPressed: () => context.read<CameraBloc>().add(ClearSelection()),
            icon: const Icon(Icons.close),
          ),
        );
        var search = Visibility(
          visible:
              selectedCameras.isEmpty && state.searchMode != SearchMode.camera,
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.search,
            onPressed: () => searchCameras(SearchMode.camera),
            icon: const Icon(Icons.search),
          ),
        );
        var showSelectedCameras = Visibility(
          visible: selectedCameras.isNotEmpty && selectedCameras.length <= 8,
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.showCameras,
            onPressed: () => showCameras(context, selectedCameras),
            icon: const Icon(Icons.camera_alt),
          ),
        );
        var switchView = const Visibility(
          //visible: defaultTargetPlatform != TargetPlatform.windows || kIsWeb,
          child: ViewModeMenu(),
        );
        var sort = Visibility(
          visible: selectedCameras.isEmpty &&
              state.viewMode != ViewMode.map &&
              state.searchMode == SearchMode.none,
          child: const SortCamerasMenu(),
        );
        var favourite = Visibility(
          child: IconButton(
            onPressed: favouriteOptionClicked,
            icon: Icon(getFavouriteIcon()),
            tooltip: getFavouriteTooltip(),
          ),
        );
        var hidden = Visibility(
          child: IconButton(
            onPressed: hideOptionClicked,
            icon: Icon(getHiddenIcon()),
            tooltip: getHiddenTooltip(),
          ),
        );
        var selectAll = Visibility(
          visible: selectedCameras.isNotEmpty &&
              selectedCameras.length < state.displayedCameras.length,
          child: IconButton(
            onPressed: () => context.read<CameraBloc>().add(SelectAll()),
            icon: const Icon(Icons.select_all),
            tooltip: AppLocalizations.of(context)!.selectAll,
          ),
        );
        var random = Visibility(
          visible: selectedCameras.isEmpty,
          child: IconButton(
            onPressed: showRandomCamera,
            icon: const Icon(Icons.casino),
            tooltip: AppLocalizations.of(context)!.random,
          ),
        );
        var shuffle = Visibility(
          visible: selectedCameras.isEmpty,
          child: IconButton(
            onPressed: () => showCameras(
              context,
              state.visibleCameras,
              shuffle: true,
            ),
            icon: const Icon(Icons.shuffle),
            tooltip: AppLocalizations.of(context)!.shuffle,
          ),
        );
        var about = Visibility(
          visible: selectedCameras.isEmpty,
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.about,
            icon: const Icon(Icons.info),
            onPressed: () => showAbout(context),
          ),
        );
        var searchNeighbourhood = Visibility(
          visible: selectedCameras.isEmpty &&
              state.searchMode != SearchMode.neighbourhood,
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.searchNeighbourhood,
            icon: const Icon(Icons.travel_explore),
            onPressed: () => searchCameras(SearchMode.neighbourhood),
          ),
        );
        var city = Visibility(
          visible:
              selectedCameras.isEmpty && state.searchMode == SearchMode.none,
          child: const ChangeCityMenu(),
        );

        List<Visibility> visibleActions = [
          clear,
          search,
          searchNeighbourhood,
          showSelectedCameras,
          switchView,
          sort,
          favourite,
          hidden,
          city,
          selectAll,
          random,
          shuffle,
          about,
        ].where((action) => action.visible).toList();
        List<Visibility> alwaysShowActions = [
          sort,
          switchView,
          city,
        ].where((action) => action.visible).toList();
        // the number of 48-width buttons that can fit in 1/4 the width of the window
        int maxActions = (MediaQuery.of(context).size.width / 4 / 48).floor();
        if (visibleActions.length > maxActions) {
          List<Visibility> overflowActions = [];
          for (int i = maxActions; i < visibleActions.length; i++) {
            if (alwaysShowActions.contains(visibleActions[i])) {
              continue;
            } else {
              overflowActions.add(visibleActions[i]);
            }
          }
          visibleActions.removeWhere(overflowActions.contains);

          List<PopupMenuEntry<IconButton>> overflowMenuItems =
              overflowActions.map((visibility) {
            IconButton iconButton = visibility.child as IconButton;
            bool checked = ((visibility == hidden) &&
                    (state.filterMode == FilterMode.hidden)) ||
                ((visibility == favourite) &&
                    (state.filterMode == FilterMode.favourite));
            return OverflowMenuItem(iconButton: iconButton, checked: checked);
          }).toList();

          var more = Visibility(
            child: PopupMenuButton<IconButton>(
              tooltip: AppLocalizations.of(context)!.more,
              position: PopupMenuPosition.under,
              itemBuilder: (context) => overflowMenuItems,
              onSelected: (iconButton) => iconButton.onPressed?.call(),
            ),
          );
          visibleActions.add(more);
        }
        return Row(children: visibleActions);
      },
    );
  }

  void showAbout(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: AppLocalizations.of(context)!.appName,
        applicationVersion: 'Version ${packageInfo.version}',
      );
    }
  }

  void showCameras(
    BuildContext context,
    List<Camera> cameras, {
    bool shuffle = false,
  }) {
    if (cameras.isNotEmpty) {
      Navigator.pushNamed(
        context,
        CameraPage.routeName,
        arguments: [cameras, shuffle],
      );
    }
  }
}

class OverflowMenuItem extends PopupMenuItem<IconButton> {
  final IconButton iconButton;
  final bool checked;

  OverflowMenuItem({
    super.key,
    required this.iconButton,
    this.checked = false,
  }) : super(
          child: Row(
            children: [
              Expanded(flex: 25, child: iconButton.icon),
              Expanded(flex: 50, child: Text(iconButton.tooltip ?? '')),
              Expanded(
                flex: 25,
                child: Visibility(
                  visible: checked,
                  child: const Icon(Icons.check),
                ),
              ),
            ],
          ),
          padding: EdgeInsets.zero,
          value: iconButton,
        );
}

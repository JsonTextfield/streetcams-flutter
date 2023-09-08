import 'dart:math';

import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streetcams_flutter/ui/widgets/menus/overflow_action.dart';
import 'package:streetcams_flutter/ui/widgets/menus/toolbar_action.dart';

import '../../../blocs/camera_bloc.dart';
import '../../../entities/camera.dart';
import '../../../entities/city.dart';
import '../../pages/camera_page.dart';
import 'action.dart';
import 'radio_menu_item.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building action bar');
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        List<Action> visibleActions = getActions(context).where((action) {
          return action.condition;
        }).toList();

        // the number of 48-width buttons that can fit in 1/3 the width of the window
        int maxActions = (MediaQuery.sizeOf(context).width / 3 / 48).floor();
        if (maxActions > 0 && visibleActions.length > maxActions) {
          List<Action> overflowActions = visibleActions.sublist(maxActions - 1);
          visibleActions = visibleActions.sublist(0, maxActions - 1);

          List<PopupMenuItem> overflowMenuItems = overflowActions.map((action) {
            if (action.popupMenuItems.isEmpty) {
              return PopupMenuItem(
                onTap: action.onClick,
                child: OverflowAction(action: action),
              );
            }
            return PopupMenuItem(
              onTap: action.onClick,
              padding: EdgeInsets.zero,
              child: PopupMenuButton(
                position: PopupMenuPosition.under,
                tooltip: action.tooltip,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: OverflowAction(action: action),
                ),
                itemBuilder: (context) => action.popupMenuItems,
              ),
            );
          }).toList();

          Action more = Action(
            tooltip: AppLocalizations.of(context)!.more,
            icon: Icons.more_vert_rounded,
            popupMenuItems: overflowMenuItems,
          );
          visibleActions.add(more);
        }
        List<Widget> toolbarActions = visibleActions.map((action) {
          if (action.popupMenuItems.isNotEmpty) {
            return PopupMenuButton(
              position: PopupMenuPosition.under,
              icon: Icon(action.icon),
              tooltip: action.tooltip,
              itemBuilder: (context) => action.popupMenuItems,
            );
          }
          return ToolbarAction(action: action);
        }).toList();
        return Row(children: toolbarActions);
      },
    );
  }

  List<Action> getActions(BuildContext context) {
    CameraState cameraState = context.read<CameraBloc>().state;

    void filterCameras(FilterMode filterMode) {
      context.read<CameraBloc>().add(FilterCamera(filterMode: filterMode));
    }

    void searchCameras(SearchMode searchMode) {
      context.read<CameraBloc>().add(SearchCameras(searchMode: searchMode));
    }

    Action clear = Action(
      icon: Icons.clear_rounded,
      tooltip: AppLocalizations.of(context)!.clear,
      onClick: () => context.read<CameraBloc>().add(ClearSelection()),
    );

    List<Camera> selectedCameras = cameraState.selectedCameras;

    Action view = Action(
      condition: selectedCameras.length <= 8,
      icon: Icons.camera_alt_rounded,
      tooltip: AppLocalizations.of(context)!.showCameras,
      onClick: () => showCameras(context, selectedCameras),
    );

    bool allFav = selectedCameras.every((cam) => cam.isFavourite);
    String favToolTip = allFav
        ? AppLocalizations.of(context)!.unfavourite
        : AppLocalizations.of(context)!.favourite;
    IconData favIcon = allFav ? Icons.star_border_rounded : Icons.star_rounded;
    Action favourite = Action(
      icon: favIcon,
      tooltip: favToolTip,
      onClick: () {
        context.read<CameraBloc>().favouriteSelectedCameras(!allFav);
      },
    );

    bool allIsHidden = selectedCameras.every((cam) => !cam.isVisible);
    String hideToolTip = allIsHidden
        ? AppLocalizations.of(context)!.unhide
        : AppLocalizations.of(context)!.hide;
    IconData hideIcon =
        allIsHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded;

    Action hide = Action(
      icon: hideIcon,
      tooltip: hideToolTip,
      onClick: () {
        context.read<CameraBloc>().hideSelectedCameras(allIsHidden);
      },
    );

    Action selectAll = Action(
      condition: selectedCameras.length < cameraState.displayedCameras.length,
      icon: Icons.select_all_rounded,
      tooltip: AppLocalizations.of(context)!.selectAll,
      onClick: () => context.read<CameraBloc>().add(SelectAll()),
    );

    Action search = Action(
      condition: cameraState.status == CameraStatus.success &&
          cameraState.searchMode != SearchMode.camera,
      icon: Icons.search_rounded,
      tooltip: AppLocalizations.of(context)!.search,
      onClick: () => searchCameras(SearchMode.camera),
    );

    Action searchNeighbourhood = Action(
      condition: cameraState.status == CameraStatus.success &&
          cameraState.searchMode != SearchMode.neighbourhood,
      icon: Icons.travel_explore_rounded,
      tooltip: AppLocalizations.of(context)!.searchNeighbourhood,
      onClick: () => searchCameras(SearchMode.neighbourhood),
    );

    String getTooltip(ViewMode viewMode) {
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
        ViewMode.list => Icons.list_rounded
      };
    }

    void changeViewMode(ViewMode viewMode) {
      Navigator.pop(context);
      context.read<CameraBloc>().add(ReloadCameras(viewMode: viewMode));
    }

    Action switchView = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: getIcon(cameraState.viewMode),
      tooltip: getTooltip(cameraState.viewMode),
      popupMenuItems: [
        RadioMenuItem<ViewMode>(
          value: ViewMode.list,
          text: AppLocalizations.of(context)!.list,
          groupValue: cameraState.viewMode,
          onChanged: changeViewMode,
          onTap: () => changeViewMode(ViewMode.list),
        ),
        RadioMenuItem<ViewMode>(
          value: ViewMode.map,
          text: AppLocalizations.of(context)!.map,
          groupValue: cameraState.viewMode,
          onChanged: changeViewMode,
          onTap: () => changeViewMode(ViewMode.map),
        ),
        RadioMenuItem<ViewMode>(
          value: ViewMode.gallery,
          text: AppLocalizations.of(context)!.gallery,
          groupValue: cameraState.viewMode,
          onChanged: changeViewMode,
          onTap: () => changeViewMode(ViewMode.gallery),
        ),
      ],
    );

    void changeSortMode(SortMode sortMode) {
      Navigator.pop(context);
      context.read<CameraBloc>().add(SortCameras(sortMode: sortMode));
    }

    Action sort = Action(
      condition: cameraState.status == CameraStatus.success &&
          cameraState.viewMode != ViewMode.map,
      icon: Icons.sort_rounded,
      tooltip: AppLocalizations.of(context)!.sort,
      popupMenuItems: [
        RadioMenuItem<SortMode>(
          value: SortMode.name,
          text: AppLocalizations.of(context)!.sortName,
          groupValue: cameraState.sortMode,
          onChanged: changeSortMode,
          onTap: () => changeSortMode(SortMode.name),
        ),
        RadioMenuItem<SortMode>(
          value: SortMode.distance,
          text: AppLocalizations.of(context)!.sortDistance,
          groupValue: cameraState.sortMode,
          onChanged: changeSortMode,
          onTap: () => changeSortMode(SortMode.distance),
        ),
        RadioMenuItem<SortMode>(
          value: SortMode.neighbourhood,
          text: AppLocalizations.of(context)!.sortNeighbourhood,
          groupValue: cameraState.sortMode,
          onChanged: changeSortMode,
          onTap: () => changeSortMode(SortMode.neighbourhood),
        ),
      ],
    );

    void changeCity(City city) {
      Navigator.pop(context);
      context.read<CameraBloc>().changeCity(city);
    }

    Action city = Action(
      condition: cameraState.searchMode == SearchMode.none,
      icon: Icons.location_city_rounded,
      tooltip: AppLocalizations.of(context)!.city,
      popupMenuItems: [
        RadioMenuItem<City>(
          value: City.ottawa,
          text: AppLocalizations.of(context)!.ottawa,
          groupValue: cameraState.city,
          onChanged: changeCity,
          onTap: () => changeCity(City.ottawa),
        ),
        RadioMenuItem<City>(
          value: City.toronto,
          text: AppLocalizations.of(context)!.toronto,
          groupValue: cameraState.city,
          onChanged: changeCity,
          onTap: () => changeCity(City.toronto),
        ),
        RadioMenuItem<City>(
          value: City.montreal,
          text: AppLocalizations.of(context)!.montreal,
          groupValue: cameraState.city,
          onChanged: changeCity,
          onTap: () => changeCity(City.montreal),
        ),
        RadioMenuItem<City>(
          value: City.calgary,
          text: AppLocalizations.of(context)!.calgary,
          groupValue: cameraState.city,
          onChanged: changeCity,
          onTap: () => changeCity(City.calgary),
        ),
      ],
    );

    Action favourites = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.star_rounded,
      tooltip: AppLocalizations.of(context)!.favourites,
      checked: cameraState.filterMode == FilterMode.favourite,
      onClick: () => filterCameras(FilterMode.favourite),
    );

    Action hidden = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.visibility_off_rounded,
      tooltip: AppLocalizations.of(context)!.hidden,
      checked: cameraState.filterMode == FilterMode.hidden,
      onClick: () => filterCameras(FilterMode.hidden),
    );

    Action random = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.casino_rounded,
      tooltip: AppLocalizations.of(context)!.random,
      onClick: () => showRandomCamera(context),
    );

    Action shuffle = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.shuffle_rounded,
      tooltip: AppLocalizations.of(context)!.shuffle,
      onClick: () {
        showCameras(
          context,
          context.read<CameraBloc>().state.visibleCameras,
          shuffle: true,
        );
      },
    );

    Action about = Action(
      tooltip: AppLocalizations.of(context)!.about,
      icon: Icons.info_rounded,
      onClick: () => showAbout(context),
    );

    if (selectedCameras.isEmpty) {
      return [
        switchView,
        sort,
        city,
        search,
        searchNeighbourhood,
        favourites,
        hidden,
        random,
        shuffle,
        about,
      ];
    }
    return [
      clear,
      view,
      favourite,
      hide,
      selectAll,
    ];
  }

  void showRandomCamera(BuildContext context) {
    List<Camera> visibleCameras =
        context.read<CameraBloc>().state.visibleCameras;
    if (visibleCameras.isNotEmpty) {
      showCameras(
        context,
        [visibleCameras[Random().nextInt(visibleCameras.length)]],
      );
    }
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

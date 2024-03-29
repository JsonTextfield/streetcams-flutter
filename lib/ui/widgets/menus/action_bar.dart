import 'dart:math';

import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:streetcams_flutter/ui/pages/camera_page.dart';
import 'package:streetcams_flutter/ui/widgets/menus/action.dart';
import 'package:streetcams_flutter/ui/widgets/menus/toolbar_action.dart';


class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building action bar');
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        List<Action> visibleActions =
            _getActions(context).where((action) => action.condition).toList();

        // the number of 48-width buttons that can fit in 1/3 the width of the window
        int maxActions = (MediaQuery.sizeOf(context).width / 2 / 48).floor();
        if (maxActions > 0 && visibleActions.length > maxActions) {
          List<Action> overflowActions = visibleActions.sublist(maxActions - 1);
          visibleActions = visibleActions.sublist(0, maxActions - 1);
          List<Widget> overflowMenuItems = overflowActions.map(
            (action) {
              return action.children != null
                  ? SubmenuButton(
                      menuChildren: action.children ?? [],
                      leadingIcon: Icon(action.icon),
                      child: Text(action.tooltip),
                    )
                  : MenuItemButton(
                      leadingIcon: Icon(action.icon),
                      trailingIcon: action.checked
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onPressed: action.onClick,
                      child: Text(action.tooltip),
                    );
            },
          ).toList();

          Action more = Action(
            tooltip: context.translation.more,
            icon: Icons.more_vert_rounded,
            children: overflowMenuItems,
          );
          visibleActions.add(more);
        }
        List<Widget> toolbarActions = visibleActions.map((action) {
          if (action.children != null) {
            return MenuAnchor(
              builder: (context, menu, child) {
                return IconButton(
                  onPressed: () => menu.isOpen ? menu.close() : menu.open(),
                  tooltip: action.tooltip,
                  icon: Icon(action.icon),
                );
              },
              menuChildren: action.children ?? [],
            );
          }
          return ToolbarAction(action: action);
        }).toList();
        return Row(children: toolbarActions);
      },
    );
  }

  List<Action> _getActions(BuildContext context) {
    CameraState cameraState = context.read<CameraBloc>().state;

    void changeFilterMode(FilterMode filterMode) {
      context.read<CameraBloc>().add(FilterCamera(filterMode: filterMode));
    }

    void changeSearchMode(SearchMode searchMode) {
      context.read<CameraBloc>().add(SearchCameras(searchMode: searchMode));
    }

    void changeViewMode(ViewMode viewMode) {
      context.read<CameraBloc>().add(ChangeViewMode(viewMode: viewMode));
    }

    void changeSortMode(SortMode sortMode) {
      context.read<CameraBloc>().add(SortCameras(sortMode: sortMode));
    }

    void changeCity(City city) {
      context.read<CameraBloc>().changeCity(city);
    }

    void hideSelectedCameras() {
      context.read<CameraBloc>().add(HideCameras(cameraState.selectedCameras));
    }

    void favouriteSelectedCameras() {
      context
          .read<CameraBloc>()
          .add(FavouriteCameras(cameraState.selectedCameras));
    }

    List<Camera> selectedCameras = cameraState.selectedCameras;

    Action clear = Action(
      icon: Icons.clear_rounded,
      tooltip: context.translation.clear,
      onClick: () => context.read<CameraBloc>().add(SelectAll(select: false)),
    );

    Action view = Action(
      condition: selectedCameras.length <= 8,
      icon: Icons.camera_alt_rounded,
      tooltip: context.translation.showCameras,
      onClick: () => _showCameras(context, selectedCameras),
    );

    bool allFav = selectedCameras.every((cam) => cam.isFavourite);
    String favToolTip = allFav
        ? context.translation.unfavourite
        : context.translation.favourite;
    IconData favIcon = allFav ? Icons.star_border_rounded : Icons.star_rounded;
    Action favourite = Action(
      icon: favIcon,
      tooltip: favToolTip,
      onClick: favouriteSelectedCameras,
    );

    bool allHidden = selectedCameras.every((cam) => !cam.isVisible);
    String hideToolTip =
        allHidden ? context.translation.unhide : context.translation.hide;
    IconData hideIcon =
        allHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded;
    Action hide = Action(
      icon: hideIcon,
      tooltip: hideToolTip,
      onClick: hideSelectedCameras,
    );

    Action selectAll = Action(
      condition: selectedCameras.length < cameraState.displayedCameras.length,
      icon: Icons.select_all_rounded,
      tooltip: context.translation.selectAll,
      onClick: () => context.read<CameraBloc>().add(SelectAll()),
    );

    Action search = Action(
      condition: cameraState.status == CameraStatus.success &&
          cameraState.searchMode != SearchMode.camera,
      icon: Icons.search_rounded,
      tooltip: context.translation.search,
      onClick: () => changeSearchMode(SearchMode.camera),
    );

    Action searchNeighbourhood = Action(
      condition: cameraState.showSearchNeighbourhood,
      icon: Icons.travel_explore_rounded,
      tooltip: context.translation.searchNeighbourhood,
      onClick: () => changeSearchMode(SearchMode.neighbourhood),
    );

    IconData getIcon(ViewMode viewMode) {
      return switch (viewMode) {
        ViewMode.map => Icons.place,
        ViewMode.gallery => Icons.grid_view_rounded,
        ViewMode.list => Icons.list_rounded
      };
    }

    Action switchView = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: getIcon(cameraState.viewMode),
      tooltip: context.translation.getViewMode(cameraState.viewMode.name),
      children: ViewMode.values.map((ViewMode viewMode) {
        return RadioMenuButton<ViewMode>(
          value: viewMode,
          groupValue: cameraState.viewMode,
          onChanged: (_) => changeViewMode(viewMode),
          child: Text(
            context.translation.getViewMode(viewMode.name),
          ),
        );
      }).toList(),
    );

    Action sort = Action(
      condition: cameraState.status == CameraStatus.success &&
          cameraState.viewMode != ViewMode.map,
      icon: Icons.sort_rounded,
      tooltip: context.translation.sort,
      children: SortMode.values.map((SortMode sortMode) {
        return RadioMenuButton<SortMode>(
          value: sortMode,
          groupValue: cameraState.sortMode,
          onChanged: (_) => changeSortMode(sortMode),
          child: Text(context.translation.getSortMode(sortMode.name)),
        );
      }).toList(),
    );

    Action city = Action(
      condition: cameraState.searchMode == SearchMode.none,
      icon: Icons.location_city_rounded,
      tooltip: context.translation.location,
      children: City.values.map((City city) {
        return RadioMenuButton<City>(
          value: city,
          groupValue: cameraState.city,
          onChanged: (_) => changeCity(city),
          child: Text(context.translation.getCity(city.name)),
        );
      }).toList(),
    );

    Action favourites = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.star_rounded,
      tooltip: context.translation.favourites,
      checked: cameraState.filterMode == FilterMode.favourite,
      onClick: () => changeFilterMode(FilterMode.favourite),
    );

    Action hidden = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.visibility_off_rounded,
      tooltip: context.translation.hidden,
      checked: cameraState.filterMode == FilterMode.hidden,
      onClick: () => changeFilterMode(FilterMode.hidden),
    );

    Action random = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.casino_rounded,
      tooltip: context.translation.random,
      onClick: () => _showRandomCamera(context),
    );

    Action shuffle = Action(
      condition: cameraState.status == CameraStatus.success,
      icon: Icons.shuffle_rounded,
      tooltip: context.translation.shuffle,
      onClick: () => _showCameras(
        context,
        context.read<CameraBloc>().state.visibleCameras,
        shuffle: true,
      ),
    );

    Action about = Action(
      tooltip: context.translation.about,
      icon: Icons.info_rounded,
      onClick: () => _showAbout(context),
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

  void _showRandomCamera(BuildContext context) {
    List<Camera> visibleCameras =
        context.read<CameraBloc>().state.visibleCameras;
    if (visibleCameras.isNotEmpty) {
      _showCameras(
        context,
        [visibleCameras[Random().nextInt(visibleCameras.length)]],
      );
    }
  }

  void _showAbout(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: context.translation.appName,
        applicationVersion: 'Version ${packageInfo.version}',
      );
    }
  }

  void _showCameras(
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

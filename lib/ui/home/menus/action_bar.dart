import 'dart:math';

import 'package:flutter/material.dart' hide Action;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:streetcams_flutter/ui/camera/camera_page.dart';
import 'package:streetcams_flutter/ui/home/menus/toolbar_action.dart';

import 'action.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building action bar');
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        // the number of 48-width buttons that can fit in 1/3 the width of the window
        int screenWidth = MediaQuery.of(context).size.width.toInt();
        int maxActions;
        if (screenWidth < 400) {
          maxActions = (screenWidth / 4 / 48).floor();
        } else if (screenWidth < 600) {
          maxActions = (screenWidth / 3 / 48).floor();
        } else if (screenWidth < 800) {
          maxActions = (screenWidth / 2 / 48).floor();
        } else {
          maxActions = (screenWidth * 2 / 3 / 48).floor();
        }

        var visibleActions = _getActions(context).where((a) => a.isVisible);
        List<Action> toolbarActions = visibleActions.take(maxActions).toList();
        List<Action> overflowActions = visibleActions.skip(maxActions).toList();

        if (overflowActions.isNotEmpty) {
          List<Widget> overflowMenuItems =
              overflowActions.map((action) {
                return action.children != null
                    ? SubmenuButton(
                      menuChildren: action.children ?? [],
                      leadingIcon: Icon(action.icon),
                      child: Text(action.tooltip),
                    )
                    : MenuItemButton(
                      leadingIcon: Icon(action.icon),
                      trailingIcon:
                          action.isChecked
                              ? const Icon(Icons.check_rounded)
                              : null,
                      onPressed: action.onClick,
                      child: Text(action.tooltip),
                    );
              }).toList();

          Action more = Action(
            tooltip: context.translation.more,
            icon: Icons.more_vert_rounded,
            children: overflowMenuItems,
          );
          toolbarActions.add(more);
        }

        return Row(
          children:
              toolbarActions.map((action) {
                if (action.children != null) {
                  return MenuAnchor(
                    builder: (context, menu, child) {
                      return IconButton(
                        onPressed:
                            () => menu.isOpen ? menu.close() : menu.open(),
                        tooltip: action.tooltip,
                        icon: Icon(action.icon),
                      );
                    },
                    menuChildren: action.children ?? [],
                  );
                }
                return ToolbarAction(action: action);
              }).toList(),
        );
      },
    );
  }

  List<Action> _getActions(BuildContext context) {
    CameraBloc cameraBloc = context.read<CameraBloc>();
    CameraState cameraState = cameraBloc.state;

    void changeFilterMode(FilterMode filterMode) {
      cameraBloc.add(FilterCamera(filterMode: filterMode));
    }

    void changeSearchMode(SearchMode searchMode) {
      cameraBloc.add(SearchCameras(searchMode: searchMode));
    }

    void changeViewMode(ViewMode viewMode) {
      cameraBloc.add(ChangeViewMode(viewMode: viewMode));
    }

    void changeSortMode(SortMode sortMode) {
      cameraBloc.add(SortCameras(sortMode: sortMode));
    }

    void changeCity(City city) {
      cameraBloc.add(ChangeCity(city));
    }

    void changeTheme(ThemeMode theme) {
      cameraBloc.add(ChangeTheme(theme: theme));
    }

    void hideSelectedCameras() {
      cameraBloc.add(HideCameras(cameraState.selectedCameras));
    }

    void favouriteSelectedCameras() {
      cameraBloc.add(FavouriteCameras(cameraState.selectedCameras));
    }

    List<Camera> selectedCameras = cameraState.selectedCameras;

    Action clear = Action(
      icon: Icons.clear_rounded,
      tooltip: context.translation.clear,
      onClick: () => cameraBloc.add(SelectAll(select: false)),
    );

    Action view = Action(
      isVisible: selectedCameras.length <= 8,
      icon: Icons.camera_alt_rounded,
      tooltip: context.translation.showCameras,
      onClick: () => _showCameras(context, selectedCameras),
    );

    bool allFav = selectedCameras.every((cam) => cam.isFavourite);
    Action favourite = Action(
      icon: allFav ? Icons.star_border_rounded : Icons.star_rounded,
      tooltip:
          allFav
              ? context.translation.unfavourite
              : context.translation.favourite,
      onClick: favouriteSelectedCameras,
    );

    bool allHid = selectedCameras.every((cam) => !cam.isVisible);
    Action hide = Action(
      icon: allHid ? Icons.visibility_rounded : Icons.visibility_off_rounded,
      tooltip: allHid ? context.translation.unhide : context.translation.hide,
      onClick: hideSelectedCameras,
    );

    Action selectAll = Action(
      isVisible: selectedCameras.length < cameraState.displayedCameras.length,
      icon: Icons.select_all_rounded,
      tooltip: context.translation.selectAll,
      onClick: () => cameraBloc.add(SelectAll()),
    );

    Action search = Action(
      isVisible:
          cameraState.uiState == UIState.success &&
          cameraState.searchMode != SearchMode.camera,
      icon: Icons.search_rounded,
      tooltip: context.translation.search,
      onClick: () => changeSearchMode(SearchMode.camera),
    );

    Action searchNeighbourhood = Action(
      isVisible: cameraState.showSearchNeighbourhood,
      icon: Icons.travel_explore_rounded,
      tooltip: context.translation.searchNeighbourhood,
      onClick: () => changeSearchMode(SearchMode.neighbourhood),
    );

    IconData getIcon(ViewMode viewMode) {
      return switch (viewMode) {
        ViewMode.map => Icons.place,
        ViewMode.gallery => Icons.grid_view_rounded,
        ViewMode.list => Icons.list_rounded,
      };
    }

    Action switchView = Action(
      isVisible: cameraState.uiState == UIState.success,
      icon: getIcon(cameraState.viewMode),
      tooltip: context.translation.getViewMode(cameraState.viewMode.name),
      children:
          ViewMode.values.map((ViewMode viewMode) {
            return RadioMenuButton<ViewMode>(
              value: viewMode,
              groupValue: cameraState.viewMode,
              onChanged: (_) => changeViewMode(viewMode),
              child: Text(context.translation.getViewMode(viewMode.name)),
            );
          }).toList(),
    );

    Action sort = Action(
      isVisible:
          cameraState.uiState == UIState.success &&
          cameraState.viewMode != ViewMode.map,
      icon: Icons.sort_rounded,
      tooltip: context.translation.sort,
      children:
          SortMode.values.map((SortMode sortMode) {
            return RadioMenuButton<SortMode>(
              value: sortMode,
              groupValue: cameraState.sortMode,
              onChanged: (_) => changeSortMode(sortMode),
              child: Text(context.translation.getSortMode(sortMode.name)),
            );
          }).toList(),
    );

    Action city = Action(
      isVisible: cameraState.searchMode == SearchMode.none,
      icon: Icons.location_city_rounded,
      tooltip: context.translation.location,
      children:
          City.values.map((City city) {
            return RadioMenuButton<City>(
              value: city,
              groupValue: cameraState.city,
              onChanged: (_) => changeCity(city),
              child: Text(context.translation.getCity(city.name)),
            );
          }).toList(),
    );

    Action theme = Action(
      icon: Icons.brightness_medium_rounded,
      tooltip: context.translation.theme,
      children:
          ThemeMode.values.map((ThemeMode theme) {
            return RadioMenuButton<ThemeMode>(
              value: theme,
              groupValue: cameraState.theme,
              onChanged: (_) => changeTheme(theme),
              child: Text(context.translation.getTheme(theme.name)),
            );
          }).toList(),
    );

    Action favourites = Action(
      isVisible: cameraState.uiState == UIState.success,
      icon: Icons.star_rounded,
      tooltip: context.translation.favourites,
      isChecked: cameraState.filterMode == FilterMode.favourite,
      onClick: () => changeFilterMode(FilterMode.favourite),
    );

    Action hidden = Action(
      isVisible: cameraState.uiState == UIState.success,
      icon: Icons.visibility_off_rounded,
      tooltip: context.translation.hidden,
      isChecked: cameraState.filterMode == FilterMode.hidden,
      onClick: () => changeFilterMode(FilterMode.hidden),
    );

    Action random = Action(
      isVisible: cameraState.uiState == UIState.success,
      icon: Icons.casino_rounded,
      tooltip: context.translation.random,
      onClick: () => _showRandomCamera(context),
    );

    Action shuffle = Action(
      isVisible: cameraState.uiState == UIState.success,
      icon: Icons.shuffle_rounded,
      tooltip: context.translation.shuffle,
      onClick:
          () =>
              _showCameras(context, cameraState.visibleCameras, shuffle: true),
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
        theme,
        about,
      ];
    }
    return [clear, view, favourite, hide, selectAll];
  }

  void _showRandomCamera(BuildContext context) {
    List<Camera> visibleCameras =
        context.read<CameraBloc>().state.visibleCameras;
    if (visibleCameras.isNotEmpty) {
      _showCameras(context, [
        visibleCameras[Random().nextInt(visibleCameras.length)],
      ]);
    }
  }

  void _showAbout(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.translation.appName),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Version ${packageInfo.version}'),
                Text(context.translation.developedBy),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => showLicensePage(context: context),
                child: Text(context.translation.licences),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.translation.close),
              ),
            ],
          );
        },
      );
    }
  }

  void _showCameras(
    BuildContext context,
    List<Camera> cameras, {
    bool shuffle = false,
  }) {
    if (cameras.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CameraPage(cameras: cameras, isShuffling: shuffle),
        ),
      );
    }
  }
}

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../blocs/camera_bloc.dart';
import '../entities/Cities.dart';
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
          } else if (selectedCameras.every((camera) => !camera.isVisible)) {
            return AppLocalizations.of(context)!.unhide;
          }
          return AppLocalizations.of(context)!.hide;
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
          var mode =
              state.filterMode == filterMode ? FilterMode.visible : filterMode;
          context.read<CameraBloc>().add(FilterCamera(filterMode: mode));
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
            onPressed: () {
              context
                  .read<CameraBloc>()
                  .add(SearchCameras(searchMode: SearchMode.camera));
            },
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
        var switchView = Visibility(
          visible: defaultTargetPlatform != TargetPlatform.windows || kIsWeb,
          child: IconButton(
            onPressed: () {
              context
                  .read<CameraBloc>()
                  .add(ReloadCameras(showList: !state.showList));
            },
            icon: Icon(state.showList ? Icons.map : Icons.list),
            tooltip: state.showList
                ? AppLocalizations.of(context)!.map
                : AppLocalizations.of(context)!.list,
          ),
        );
        var sort = Visibility(
          visible: selectedCameras.isEmpty &&
              state.showList &&
              state.searchMode == SearchMode.none,
          child: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              void sortCameras(SortingMethod sortMode) {
                context
                    .read<CameraBloc>()
                    .add(SortCameras(sortingMethod: sortMode));
              }

              return MenuAnchor(
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
                    child:
                        Text(AppLocalizations.of(context)!.sortNeighbourhood),
                  ),
                ],
                builder: (context, controller, child) {
                  return IconButton(
                    onPressed: () {
                      controller.isOpen
                          ? controller.close()
                          : controller.open();
                    },
                    icon: const Icon(Icons.sort),
                    tooltip: AppLocalizations.of(context)!.sort,
                  );
                },
              );
            },
          ),
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
            onPressed: () {
              context
                  .read<CameraBloc>()
                  .add(SearchCameras(searchMode: SearchMode.neighbourhood));
            },
          ),
        );
        var changeCity = Visibility(
          visible: selectedCameras.isEmpty,
          child: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              void changeCity(Cities city) {
                context.read<CameraBloc>().changeCity(city);
              }

              return MenuAnchor(
                menuChildren: [
                  RadioMenuButton<Cities>(
                    value: Cities.ottawa,
                    groupValue: state.city,
                    onChanged: (_) => changeCity(Cities.ottawa),
                    child: Text(AppLocalizations.of(context)!.ottawa),
                  ),
                  RadioMenuButton<Cities>(
                    value: Cities.toronto,
                    groupValue: state.city,
                    onChanged: (_) => changeCity(Cities.toronto),
                    child: Text(AppLocalizations.of(context)!.toronto),
                  ),
                  RadioMenuButton<Cities>(
                    value: Cities.montreal,
                    groupValue: state.city,
                    onChanged: (_) => changeCity(Cities.montreal),
                    child: Text(AppLocalizations.of(context)!.montreal),
                  ),
                  RadioMenuButton<Cities>(
                    value: Cities.calgary,
                    groupValue: state.city,
                    onChanged: (_) => changeCity(Cities.calgary),
                    child: Text(AppLocalizations.of(context)!.calgary),
                  ),
                ],
                builder: (context, controller, child) {
                  return IconButton(
                    onPressed: () {
                      controller.isOpen
                          ? controller.close()
                          : controller.open();
                    },
                    icon: const Icon(Icons.location_city),
                    tooltip: AppLocalizations.of(context)!.city,
                  );
                },
              );
            },
          ),
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
          selectAll,
          random,
          shuffle,
          changeCity,
          about,
        ].where((action) => action.visible).toList();
        // the number of 48-width buttons that can fit in 1/4 the width of the window
        int maxActions = (MediaQuery.of(context).size.width / 4 / 48).floor();
        if (visibleActions.length > maxActions) {
          List<Visibility> overflowActions = [];
          for (int i = maxActions; i < visibleActions.length; i++) {
            if (visibleActions[i] == sort || visibleActions[i] == changeCity) {
              continue;
            } else {
              overflowActions.add(visibleActions[i]);
            }
          }
          visibleActions.removeWhere(overflowActions.contains);
          visibleActions.add(
            Visibility(
              child: PopupMenuButton(
                tooltip: AppLocalizations.of(context)!.more,
                position: PopupMenuPosition.under,
                itemBuilder: (context) {
                  return overflowActions.map((visibility) {
                    IconButton iconButton = visibility.child as IconButton;
                    return PopupMenuItem(
                      padding: const EdgeInsets.all(0),
                      child: ListTile(
                        leading: iconButton.icon,
                        title: Text(iconButton.tooltip ?? ''),
                        onTap: () {
                          Navigator.pop(context);
                          iconButton.onPressed?.call();
                        },
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          );
        }
        return Row(
          children: visibleActions,
        );
      },
    );
  }

  void showAbout(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationIcon: const FlutterLogo(),
        applicationName: AppLocalizations.of(context)!.appName,
        applicationVersion: 'Version ${packageInfo.version}',
      );
    }
  }

  void showCameras(
    BuildContext context,
    List<Camera> cameras, {
    shuffle = false,
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

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../blocs/camera_bloc.dart';
import '../entities/camera.dart';
import '../pages/camera_page.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void showCameras(List<Camera> cameras, {shuffle = false}) {
          if (cameras.isNotEmpty) {
            Navigator.pushNamed(
              context,
              CameraPage.routeName,
              arguments: [cameras, shuffle],
            );
          }
        }

        String getFavouriteTooltip() {
          List<Camera> selectedCameras =
              context.read<CameraBloc>().state.selectedCameras;
          if (selectedCameras.isEmpty) {
            return AppLocalizations.of(context)!.favourites;
          } else if (selectedCameras.every((camera) => camera.isFavourite)) {
            return AppLocalizations.of(context)!.unfavourite;
          }
          return AppLocalizations.of(context)!.favourite;
        }

        String getHiddenTooltip() {
          List<Camera> selectedCameras =
              context.read<CameraBloc>().state.selectedCameras;
          if (selectedCameras.isEmpty) {
            return AppLocalizations.of(context)!.hidden;
          } else if (selectedCameras.every((camera) => !camera.isVisible)) {
            return AppLocalizations.of(context)!.unhide;
          }
          return AppLocalizations.of(context)!.hide;
        }

        IconData getFavouriteIcon() {
          var selectedCameras =
              context.read<CameraBloc>().state.selectedCameras;
          if (selectedCameras.isEmpty ||
              selectedCameras.any((c) => !c.isFavourite)) {
            return Icons.star;
          }
          return Icons.star_border;
        }

        IconData getHiddenIcon() {
          var selectedCameras =
              context.read<CameraBloc>().state.selectedCameras;
          if (selectedCameras.isEmpty ||
              selectedCameras.any((c) => c.isVisible)) {
            return Icons.visibility_off;
          }
          return Icons.visibility;
        }

        void showRandomCamera() {
          var visibleCameras = context.read<CameraBloc>().state.visibleCameras;
          if (visibleCameras.isNotEmpty) {
            showCameras(
              [visibleCameras[Random().nextInt(visibleCameras.length)]],
            );
          }
        }

        void favouriteOptionClicked() {
          if (context.read<CameraBloc>().state.selectedCameras.isEmpty) {
            var filterMode = context.read<CameraBloc>().state.filterMode ==
                    FilterMode.favourite
                ? FilterMode.visible
                : FilterMode.favourite;
            context
                .read<CameraBloc>()
                .add(FilterCamera(filterMode: filterMode));
          } else {
            context.read<CameraBloc>().favouriteSelectedCameras();
          }
        }

        void hideOptionClicked() {
          if (context.read<CameraBloc>().state.selectedCameras.isEmpty) {
            var filterMode =
                context.read<CameraBloc>().state.filterMode == FilterMode.hidden
                    ? FilterMode.visible
                    : FilterMode.hidden;
            context
                .read<CameraBloc>()
                .add(FilterCamera(filterMode: filterMode));
          } else {
            context.read<CameraBloc>().hideSelectedCameras();
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

        var selectedCameras = context.read<CameraBloc>().state.selectedCameras;
        var clear = Visibility(
          visible: selectedCameras.isNotEmpty,
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.clear,
            onPressed: () => context.read<CameraBloc>().add(ClearSelection()),
            icon: const Icon(Icons.close),
          ),
        );
        var search = Visibility(
          visible: selectedCameras.isEmpty &&
              context.read<CameraBloc>().state.searchMode != SearchMode.camera,
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
            onPressed: () => showCameras(selectedCameras),
            icon: const Icon(Icons.camera_alt),
          ),
        );
        var switchView = Visibility(
          visible: defaultTargetPlatform != TargetPlatform.windows || kIsWeb,
          child: IconButton(
            onPressed: () {
              context.read<CameraBloc>().add(ReloadCameras(
                    showList: !context.read<CameraBloc>().state.showList,
                  ));
            },
            icon: Icon(context.read<CameraBloc>().state.showList
                ? Icons.map
                : Icons.list),
            tooltip: context.read<CameraBloc>().state.showList
                ? AppLocalizations.of(context)!.map
                : AppLocalizations.of(context)!.list,
          ),
        );
        var sort = Visibility(
          visible: selectedCameras.isEmpty &&
              context.read<CameraBloc>().state.showList &&
              context.read<CameraBloc>().state.searchMode == SearchMode.none,
          child: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              return PopupMenuButton(
                position: PopupMenuPosition.under,
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      padding: const EdgeInsets.all(0),
                      onTap: () {
                        context
                            .read<CameraBloc>()
                            .add(SortCameras(method: SortMode.name));
                      },
                      child: ListTile(
                        title: Text(AppLocalizations.of(context)!.sortName),
                        trailing: state.sortingMethod == SortMode.name
                            ? const Icon(Icons.check)
                            : null,
                      ),
                    ),
                    PopupMenuItem(
                      padding: const EdgeInsets.all(0),
                      onTap: () {
                        context
                            .read<CameraBloc>()
                            .add(SortCameras(method: SortMode.distance));
                      },
                      child: ListTile(
                        title: Text(AppLocalizations.of(context)!.sortDistance),
                        trailing: state.sortingMethod == SortMode.distance
                            ? const Icon(Icons.check)
                            : null,
                      ),
                    ),
                    PopupMenuItem(
                      padding: const EdgeInsets.all(0),
                      onTap: () {
                        context
                            .read<CameraBloc>()
                            .add(SortCameras(method: SortMode.neighbourhood));
                      },
                      child: ListTile(
                        title: Text(
                            AppLocalizations.of(context)!.sortNeighbourhood),
                        trailing: state.sortingMethod == SortMode.neighbourhood
                            ? const Icon(Icons.check)
                            : null,
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.sort),
                tooltip: AppLocalizations.of(context)!.sort,
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
              selectedCameras.length <
                  context.read<CameraBloc>().state.displayedCameras.length,
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
              context.read<CameraBloc>().state.visibleCameras,
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
              context.read<CameraBloc>().state.searchMode !=
                  SearchMode.neighbourhood,
          child: IconButton(
            tooltip: AppLocalizations.of(context)!.searchNeighbourhood,
            icon: const Icon(Icons.location_city),
            onPressed: () {
              context
                  .read<CameraBloc>()
                  .add(SearchCameras(searchMode: SearchMode.neighbourhood));
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
          about,
        ].where((action) => action.visible).toList();
        // the number of 48-width buttons that can fit in 1/4 the width of the window
        int maxActions = (MediaQuery.of(context).size.width / 4 / 48).floor();
        if (visibleActions.length > maxActions) {
          List<Visibility> overflowActions = [];
          for (int i = maxActions; i < visibleActions.length; i++) {
            if (visibleActions[i] == sort) {
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
}

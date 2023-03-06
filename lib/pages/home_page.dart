import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/widgets/camera_list_tile.dart';

import '../constants.dart';
import '../entities/camera.dart';
import '../entities/neighbourhood.dart';
import '../services/location_service.dart';
import '../widgets/camera_search_bar.dart';
import '../widgets/section_index.dart';
import 'camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _darkMapStyle = '';
  final flutter_map.MapController flutterMapController =
      flutter_map.MapController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    _loadMapStyle();
    super.initState();
  }

  void _loadMapStyle() async {
    _darkMapStyle = await rootBundle.loadString('assets/dark_mode.json');
  }

  List<Widget> getAppBarActions() {
    var selectedCameras = context.read<CameraBloc>().state.selectedCameras;
    var clear = Visibility(
      visible: selectedCameras.isNotEmpty,
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.clear,
        onPressed: () => setState(selectedCameras.clear),
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
    var showCameras = Visibility(
      visible: selectedCameras.isNotEmpty && selectedCameras.length <= 8,
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.showCameras,
        onPressed: () => _showCameras(selectedCameras),
        icon: const Icon(Icons.camera_alt),
      ),
    );
    var switchView = Visibility(
      visible: defaultTargetPlatform != TargetPlatform.windows || kIsWeb,
      child: IconButton(
        onPressed: () {
          context.read<CameraBloc>().add(CameraLoaded(
              showList: !context.read<CameraBloc>().state.showList));
        },
        icon: Icon(
            context.read<CameraBloc>().state.showList ? Icons.map : Icons.list),
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
                    title:
                        Text(AppLocalizations.of(context)!.sortNeighbourhood),
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
        onPressed: () => setState(_favouriteOptionClicked),
        icon: Icon(getFavouriteIcon()),
        tooltip: _getFavouriteTooltip(),
      ),
    );
    var hidden = Visibility(
      child: IconButton(
        onPressed: () => setState(_hideOptionClicked),
        icon: Icon(getHiddenIcon()),
        tooltip: getHiddenTooltip(),
      ),
    );
    var selectAll = Visibility(
      visible: selectedCameras.isNotEmpty &&
          selectedCameras.length <
              context.read<CameraBloc>().state.displayedCameras.length,
      child: IconButton(
        onPressed: () {
          setState(() => selectedCameras =
              context.read<CameraBloc>().state.displayedCameras.toList());
        },
        icon: const Icon(Icons.select_all),
        tooltip: AppLocalizations.of(context)!.selectAll,
      ),
    );
    var random = Visibility(
      visible: selectedCameras.isEmpty,
      child: IconButton(
        onPressed: _showRandomCamera,
        icon: const Icon(Icons.casino),
        tooltip: AppLocalizations.of(context)!.random,
      ),
    );
    var shuffle = Visibility(
      visible: selectedCameras.isEmpty,
      child: IconButton(
        onPressed: () => _showCameras(
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
      showCameras,
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
    return visibleActions;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                if (state.searchMode == SearchMode.none) {
                  return GestureDetector(
                    child: Text(state.selectedCameras.isEmpty
                        ? AppLocalizations.of(context)!.appName
                        : '${state.selectedCameras.length} selected'),
                    onTap: () => _moveToListPosition(0),
                  );
                } else if (state.searchMode == SearchMode.camera) {
                  return CameraSearchBar(
                    controller: _textEditingController,
                    hintText: AppLocalizations.of(context)!
                        .searchCameras(state.visibleCameras.length),
                    onChanged: (query) {
                      context.read<CameraBloc>().add(SearchCameras(
                          searchMode: SearchMode.camera, query: query));
                    },
                    onBackPressed: () {
                      _textEditingController.clear();
                      context
                          .read<CameraBloc>()
                          .add(SearchCameras(searchMode: SearchMode.none));
                    },
                    onClearPressed: _textEditingController.clear,
                  );
                }
                //searchMode is SearchMode.neighbourhood
                return Autocomplete<String>(
                  optionsBuilder: (textEditingController) {
                    return getAutoCompleteOptions(
                      textEditingController,
                      context.read<CameraBloc>().neighbourhoods,
                    );
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      focusNode: focusNode,
                      controller: controller,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      onChanged: (query) {
                        context.read<CameraBloc>().add(SearchCameras(
                              searchMode: SearchMode.neighbourhood,
                              query: query,
                            ));
                      },
                      decoration: InputDecoration(
                        icon: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            controller.clear();
                            context.read<CameraBloc>().add(
                                SearchCameras(searchMode: SearchMode.none));
                          },
                        ),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clear,
                              )
                            : null,
                        hintText: AppLocalizations.of(context)!
                            .searchNeighbourhoods(state.neighbourhoods.length),
                      ),
                    );
                  },
                );
              },
            ),
            actions: getAppBarActions(),
            backgroundColor:
                state.selectedCameras.isEmpty ? null : Constants.accentColour,
          ),
          body: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              switch (state.status) {
                case CameraStatus.failure:
                  return Center(
                    child: Text(AppLocalizations.of(context)!.error),
                  );
                case CameraStatus.success:
                  return IndexedStack(
                    index: state.showList ? 0 : 1,
                    children: [
                      getListView(state.displayedCameras),
                      getMapView(state.displayedCameras),
                    ],
                  );
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }

  void showAbout(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      showAboutDialog(
        context: context,
        applicationName: AppLocalizations.of(context)!.appName,
        applicationVersion: 'Version ${packageInfo.version}',
      );
    }
  }

  String _getFavouriteTooltip() {
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
    var selectedCameras = context.read<CameraBloc>().state.selectedCameras;
    if (selectedCameras.isEmpty || selectedCameras.any((c) => !c.isFavourite)) {
      return Icons.star;
    }
    return Icons.star_border;
  }

  IconData getHiddenIcon() {
    var selectedCameras = context.read<CameraBloc>().state.selectedCameras;
    if (selectedCameras.isEmpty || selectedCameras.any((c) => c.isVisible)) {
      return Icons.visibility_off;
    }
    return Icons.visibility;
  }

  Widget getListView(List<Camera> cameras) {
    debugPrint('building listview');
    return BlocBuilder<CameraBloc, CameraState>(builder: (context, state) {
      return Row(children: [
        if (state.filterMode == FilterMode.visible &&
            state.sortingMethod == SortMode.name)
          Flexible(
            flex: 0,
            child: SectionIndex(
              data: cameras.map((cam) => cam.sortableName).toList(),
              callback: _moveToListPosition,
            ),
          ),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemCount: cameras.length + 1,
            itemBuilder: (context, i) {
              if (i == cameras.length) {
                return ListTile(
                  title: Center(
                    child: Text(
                      AppLocalizations.of(context)!.cameras(cameras.length),
                    ),
                  ),
                );
              }
              var camera = cameras[i];
              return CameraListTile(
                  camera: camera,
                  onTap: () {
                    if (context
                        .read<CameraBloc>()
                        .state
                        .selectedCameras
                        .isEmpty) {
                      _showCameras([camera]);
                    } else {
                      _selectCamera(camera);
                    }
                  },
                  onLongPress: () => _selectCamera(camera),
                  onFavouriteTapped: (isFavourite) {
                    camera.isFavourite = !camera.isFavourite;
                    context.read<CameraBloc>().writeSharedPrefs();
                    _resetDisplayedCameras();
                  },
                  onDismissed: (_) {
                    camera.isVisible = !camera.isVisible;
                    context.read<CameraBloc>().writeSharedPrefs();
                    _resetDisplayedCameras();
                  });
            },
          ),
        ),
      ]);
    });
  }

  void _moveToListPosition(int index) {
    _itemScrollController.jumpTo(index: index);
  }

  Widget getMapView(List<Camera> cameras) {
    LatLngBounds? bounds;
    LatLng initialCameraPosition = const LatLng(45.4, -75.7);
    if (cameras.isNotEmpty) {
      var minLat = cameras[0].location.lat;
      var maxLat = cameras[0].location.lat;
      var minLon = cameras[0].location.lon;
      var maxLon = cameras[0].location.lon;
      for (var camera in cameras) {
        minLat = min(minLat, camera.location.lat);
        maxLat = max(maxLat, camera.location.lat);
        minLon = min(minLon, camera.location.lon);
        maxLon = max(maxLon, camera.location.lon);
      }
      initialCameraPosition = LatLng(
        (minLat + maxLat) / 2,
        (minLon + maxLon) / 2,
      );
      bounds = LatLngBounds(
        southwest: LatLng(minLat, minLon),
        northeast: LatLng(maxLat, maxLon),
      );
    }
    return FutureBuilder(
      future: LocationService.getCurrentLocation(),
      builder: (context, data) {
        bool showLocation = data.hasData;
        return GoogleMap(
          myLocationButtonEnabled: showLocation,
          myLocationEnabled: showLocation,
          cameraTargetBounds: CameraTargetBounds(bounds),
          initialCameraPosition: CameraPosition(target: initialCameraPosition),
          minMaxZoomPreference: const MinMaxZoomPreference(9, 16),
          markers: getMapMarkers(cameras),
          onMapCreated: (controller) {
            if (Theme.of(context).brightness == Brightness.dark) {
              controller.setMapStyle(_darkMapStyle);
            }
          },
        );
      },
    );
  }

  Set<Marker> getMapMarkers(List<Camera> cameras) {
    return cameras
        .map((camera) => Marker(
              markerId: MarkerId(camera.id.toString()),
              position: LatLng(camera.location.lat, camera.location.lon),
              infoWindow: InfoWindow(
                title: camera.name,
                onTap: () => _showCameras([camera]),
              ),
            ))
        .toSet();
  }

  Iterable<String> getAutoCompleteOptions(
    TextEditingValue value,
    List<Neighbourhood> neighbourhoods,
  ) {
    if (value.text.isEmpty) {
      return [];
    }
    return neighbourhoods.map((n) => n.name).where(
      (name) {
        return name.toLowerCase().contains(value.text.trim().toLowerCase());
      },
    );
  }

  void _showRandomCamera() {
    var visibleCameras = context.read<CameraBloc>().state.visibleCameras;
    if (visibleCameras.isNotEmpty) {
      _showCameras([visibleCameras[Random().nextInt(visibleCameras.length)]]);
    }
  }

  void _favouriteOptionClicked() {
    if (context.read<CameraBloc>().state.selectedCameras.isEmpty) {
      var filterMode =
          context.read<CameraBloc>().state.filterMode == FilterMode.favourite
              ? FilterMode.visible
              : FilterMode.favourite;
      context.read<CameraBloc>().add(FilterCamera(filterMode: filterMode));
    } else {
      context.read<CameraBloc>().favouriteSelectedCameras();
    }
  }

  void _hideOptionClicked() {
    if (context.read<CameraBloc>().state.selectedCameras.isEmpty) {
      var filterMode =
          context.read<CameraBloc>().state.filterMode == FilterMode.hidden
              ? FilterMode.visible
              : FilterMode.hidden;
      context.read<CameraBloc>().add(FilterCamera(filterMode: filterMode));
    } else {
      context.read<CameraBloc>().hideSelectedCameras();
    }
  }

  void _resetDisplayedCameras() {
    context.read<CameraBloc>().add(SearchCameras());
  }

  /// Adds/removes a [Camera] to/from the selected camera list.
  void _selectCamera(Camera camera) {
    context.read<CameraBloc>().add(SelectCamera(camera: camera));
  }

  void _showCameras(List<Camera> cameras, {shuffle = false}) {
    if (cameras.isNotEmpty) {
      Navigator.pushNamed(
        context,
        CameraPage.routeName,
        arguments: [cameras, shuffle],
      );
    }
  }
}

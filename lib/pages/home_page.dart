import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl_standalone.dart';
import 'package:latlong2/latlong.dart' as latlon;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/widgets/camera_list_tile.dart';

import '../constants.dart';
import '../entities/camera.dart';
import '../entities/neighbourhood.dart';
import '../services/location_service.dart';
import '../widgets/section_index.dart';
import 'camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SearchMode searchMode = SearchMode.none;
  String _darkMapStyle = '';
  final flutter_map.MapController flutterMapController =
      flutter_map.MapController();
  final ItemScrollController _itemScrollController = ItemScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final int _maxCameras = 8;
  bool _showList = true;
  bool _isFiltered = false;
  SharedPreferences? _prefs;
  List<Camera> _allCameras = [];
  List<Camera> _displayedCameras = [];
  List<Camera> _selectedCameras = [];
  List<Neighbourhood> _neighbourhoods = [];

  @override
  void initState() {
    _setLocale();
    _downloadAll();
    super.initState();
  }

  void _setLocale() async {
    BilingualObject.locale = await findSystemLocale();
  }

  List<Widget> getAppBarActions() {
    var clear = Visibility(
      visible: _selectedCameras.isNotEmpty,
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.clear,
        onPressed: () => setState(_selectedCameras.clear),
        icon: const Icon(Icons.close),
      ),
    );
    var search = Visibility(
      visible: _selectedCameras.isEmpty && searchMode != SearchMode.camera,
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.search,
        onPressed: () {
          setState(() {
            searchMode = SearchMode.camera;
          });
        },
        icon: const Icon(Icons.search),
      ),
    );
    var showCameras = Visibility(
      visible:
          _selectedCameras.isNotEmpty && _selectedCameras.length <= _maxCameras,
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.showCameras,
        onPressed: () => _showCameras(_selectedCameras),
        icon: const Icon(Icons.camera_alt),
      ),
    );
    var switchView = Visibility(
      visible: defaultTargetPlatform != TargetPlatform.windows || kIsWeb,
      child: IconButton(
        onPressed: (() => setState(() => _showList = !_showList)),
        icon: Icon(_showList ? Icons.map : Icons.list),
        tooltip: _showList
            ? AppLocalizations.of(context)!.map
            : AppLocalizations.of(context)!.list,
      ),
    );
    var sort = Visibility(
      visible: _selectedCameras.isEmpty &&
          _showList &&
          searchMode == SearchMode.none,
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
                        .add(SortCameras(method: CameraSortingMethod.name));
                  },
                  child: ListTile(
                    title: Text(AppLocalizations.of(context)!.sortName),
                    trailing: state.sortingMethod == CameraSortingMethod.name
                        ? const Icon(Icons.check)
                        : null,
                  ),
                ),
                PopupMenuItem(
                  padding: const EdgeInsets.all(0),
                  onTap: () {
                    context
                        .read<CameraBloc>()
                        .add(SortCameras(method: CameraSortingMethod.distance));
                  },
                  child: ListTile(
                    title: Text(AppLocalizations.of(context)!.sortDistance),
                    trailing:
                        state.sortingMethod == CameraSortingMethod.distance
                            ? const Icon(Icons.check)
                            : null,
                  ),
                ),
                PopupMenuItem(
                  padding: const EdgeInsets.all(0),
                  onTap: () {
                    context.read<CameraBloc>().add(
                        SortCameras(method: CameraSortingMethod.neighbourhood));
                  },
                  child: ListTile(
                    title: Text(AppLocalizations.of(context)!.sortNeighbourhood),
                    trailing:
                        state.sortingMethod == CameraSortingMethod.neighbourhood
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
        icon: getFavouriteIcon(),
        tooltip: _getFavouriteTooltip(),
      ),
    );
    var hidden = Visibility(
      child: IconButton(
        onPressed: () => setState(_hideOptionClicked),
        icon: getHiddenIcon(),
        tooltip: getHiddenTooltip(),
      ),
    );
    var selectAll = Visibility(
      visible: _selectedCameras.isNotEmpty &&
          _selectedCameras.length < _displayedCameras.length,
      child: IconButton(
        onPressed: () {
          setState(() => _selectedCameras = _displayedCameras.toList());
        },
        icon: const Icon(Icons.select_all),
        tooltip: AppLocalizations.of(context)!.selectAll,
      ),
    );
    var random = Visibility(
      visible: _selectedCameras.isEmpty,
      child: IconButton(
        onPressed: _showRandomCamera,
        icon: const Icon(Icons.casino),
        tooltip: AppLocalizations.of(context)!.random,
      ),
    );
    var shuffle = Visibility(
      visible: _selectedCameras.isEmpty,
      child: IconButton(
        onPressed: () => _showCameras(
          _allCameras.where((element) => element.isVisible).toList(),
          shuffle: true,
        ),
        icon: const Icon(Icons.shuffle),
        tooltip: AppLocalizations.of(context)!.shuffle,
      ),
    );
    var about = Visibility(
      visible: _selectedCameras.isEmpty,
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.about,
        icon: const Icon(Icons.info),
        onPressed: () => showAbout(context),
      ),
    );
    var searchNeighbourhood = Visibility(
      visible:
          _selectedCameras.isEmpty && searchMode != SearchMode.neighbourhood,
      child: IconButton(
        tooltip: AppLocalizations.of(context)!.searchNeighbourhood,
        icon: const Icon(Icons.location_city),
        onPressed: () => setState(() => searchMode = SearchMode.neighbourhood),
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
              return overflowActions
                  .map((visibility) =>
                      _convertToOverflowAction(visibility.child as IconButton))
                  .toList();
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
                if (true) {
                  return GestureDetector(
                    child: Text(_selectedCameras.isEmpty
                        ? AppLocalizations.of(context)!.appName
                        : '${_selectedCameras.length} selected'),
                    onTap: () => _moveToListPosition(0),
                  );
                } else if (searchMode == SearchMode.camera) {
                  return FilterTextField(
                    controller: _textEditingController,
                    hintText: AppLocalizations.of(context)!
                        .searchCameras(_displayedCameras.length),
                    onChanged: _filterDisplayedCamerasWithString,
                    onBackPressed: _closeSearchBar,
                    onClearPressed: _textEditingController.clear,
                  );
                }
                //searchMode is SearchMode.neighbourhood
                return Autocomplete<String>(
                  optionsBuilder: getAutoCompleteOptions,
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      focusNode: focusNode,
                      controller: controller,
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.search,
                      onChanged: _filterDisplayedCamerasByNeighbourhood,
                      decoration: InputDecoration(
                        icon: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _closeSearchBar,
                        ),
                        suffixIcon: controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clear,
                              )
                            : null,
                        hintText: AppLocalizations.of(context)!
                            .searchNeighbourhoods(_neighbourhoods.length),
                      ),
                    );
                  },
                );
              },
            ),
            actions: getAppBarActions(),
            backgroundColor:
                _selectedCameras.isEmpty ? null : Constants.accentColour,
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
                    index: _showList ? 0 : 1,
                    children: [
                      getListView(state.allCameras),
                      getMapView(state.allCameras),
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

  Widget _getTitleBar() {
    return TextField(
      controller: _textEditingController,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      onChanged: _filterDisplayedCamerasWithString,
      decoration: InputDecoration(
        icon: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _closeSearchBar,
        ),
        suffixIcon: _textEditingController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _textEditingController.clear();
                    _filterDisplayedCamerasWithString('');
                  });
                },
              )
            : null,
        hintText: AppLocalizations.of(context)!
            .searchCameras(_displayedCameras.length),
      ),
    );
  }

  PopupMenuItem _convertToOverflowAction(IconButton iconButton) {
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
  }

  void showAbout(BuildContext context) async {
    var packageInfo = await PackageInfo.fromPlatform();
    showAboutDialog(
      context: context,
      applicationName: AppLocalizations.of(context)!.appName,
      applicationVersion: 'Version ${packageInfo.version}',
    );
  }

  String _getFavouriteTooltip() {
    if (_selectedCameras.isEmpty) {
      return AppLocalizations.of(context)!.favourites;
    } else if (_selectedCameras.every((camera) => camera.isFavourite)) {
      return AppLocalizations.of(context)!.unfavourite;
    }
    return AppLocalizations.of(context)!.favourite;
  }

  String getHiddenTooltip() {
    if (_selectedCameras.isEmpty) {
      return AppLocalizations.of(context)!.hidden;
    } else if (_selectedCameras.every((camera) => !camera.isVisible)) {
      return AppLocalizations.of(context)!.unhide;
    }
    return AppLocalizations.of(context)!.hide;
  }

  Icon getFavouriteIcon() {
    if (_selectedCameras.isEmpty ||
        _selectedCameras.any((camera) => !camera.isFavourite)) {
      return const Icon(Icons.star);
    }
    return const Icon(Icons.star_border);
  }

  Icon getHiddenIcon() {
    if (_selectedCameras.isEmpty || _selectedCameras.any((c) => c.isVisible)) {
      return const Icon(Icons.visibility_off);
    }
    return const Icon(Icons.visibility);
  }

  Widget getListView(List<Camera> cameras) {
    debugPrint('building listview');
    return BlocBuilder<CameraBloc, CameraState>(builder: (context, state) {
      return Row(children: [
        if (!_isFiltered && state.sortingMethod == CameraSortingMethod.name)
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
                    if (_selectedCameras.isEmpty) {
                      _showCameras([camera]);
                    } else {
                      _selectCamera(camera);
                    }
                  },
                  onLongPress: () => _selectCamera(camera),
                  onFavouriteTapped: (isFavourite) {
                    camera.isFavourite = !camera.isFavourite;
                    _writeSharedPrefs();
                  },
                  onDismissed: (_) {
                    setState(() {
                      camera.isVisible = !camera.isVisible;
                      _writeSharedPrefs();
                      _resetDisplayedCameras();
                    });
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

  Widget getListViewBuilder() {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemCount: _displayedCameras.length + 1,
      itemBuilder: (context, i) {
        if (i == _displayedCameras.length) {
          return ListTile(
            title: Center(
              child: Text(
                AppLocalizations.of(context)!.cameras(_displayedCameras.length),
              ),
            ),
          );
        }
        return getCameraListTile(i);
      },
    );
  }

  Widget getCameraListTile(int i) {
    return ListTile(
      tileColor:
          _selectedCameras.contains(_displayedCameras[i]) ? Colors.blue : null,
      dense: true,
      title: Text(
        _displayedCameras[i].name,
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: _displayedCameras[i].neighbourhood.isNotEmpty
          ? Text(_displayedCameras[i].neighbourhood)
          : null,
      trailing: IconButton(
        icon: Icon(
          _displayedCameras[i].isFavourite ? Icons.star : Icons.star_border,
        ),
        color: _displayedCameras[i].isFavourite ? Colors.yellow : null,
        onPressed: () {
          setState(() {
            _displayedCameras[i].isFavourite =
                !_displayedCameras[i].isFavourite;
            _writeSharedPrefs();
          });
        },
      ),
      onTap: () {
        if (_selectedCameras.isEmpty) {
          _showCameras([_displayedCameras[i]]);
        } else {
          setState(() => _selectCamera(_displayedCameras[i]));
        }
      },
      onLongPress: () => setState(() => _selectCamera(_displayedCameras[i])),
    );
  }

  Widget getMapView(List<Camera> cameras) {
    LatLngBounds? bounds;
    LatLng initialCameraPosition = const LatLng(45.4, -75.7);
    flutter_map.LatLngBounds? boundsFlutterMaps;
    latlon.LatLng initCamPos = latlon.LatLng(45.4, -75.7);
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
      initCamPos = latlon.LatLng(
        (minLat + maxLat) / 2,
        (minLon + maxLon) / 2,
      );
      boundsFlutterMaps = flutter_map.LatLngBounds.fromPoints([
        latlon.LatLng(minLat, minLon),
        latlon.LatLng(maxLat, maxLon),
      ]);
    }
    /*if (defaultTargetPlatform == TargetPlatform.windows) {
      return flutter_map.FlutterMap(
        mapController: flutterMapController,
        options: flutter_map.MapOptions(
          onMapReady: () {
            if (boundsFlutterMaps != null) {
              flutterMapController.fitBounds(boundsFlutterMaps);
            }
          },
          bounds: boundsFlutterMaps,
          boundsOptions: const flutter_map_api.FitBoundsOptions(inside: true),
          center: initCamPos,
          minZoom: 9,
          maxZoom: 16,
        ),
        children: [
          flutter_map.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.jsontextfield.streetcams_flutter',
          ),
          flutter_map.MarkerLayer(
            markers: _displayedCameras.map((camera) {
              return flutter_map.Marker(
                point: latlon.LatLng(camera.location.lat, camera.location.lon),
                anchorPos: flutter_map.AnchorPos.exactly(
                  flutter_map.Anchor(5.0, -20.0),
                ),
                builder: (context) => GestureDetector(
                  child: Stack(
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 48,
                        color: _selectedCameras.contains(camera)
                            ? Constants.accentColour
                            : camera.isFavourite
                                ? Colors.yellow
                                : Colors.red,
                      ),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 48,
                      ),
                    ],
                  ),
                  onTap: () => _selectedCameras.isNotEmpty
                      ? setState(() => _selectCamera(camera))
                      : _showCameras([camera]),
                  onLongPress: () => setState(() => _selectCamera(camera)),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }*/
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
              icon: _getMarkerIcon(camera),
              markerId: MarkerId(camera.id.toString()),
              position: LatLng(camera.location.lat, camera.location.lon),
              infoWindow: InfoWindow(
                title: camera.name,
                onTap: () => _showCameras([camera]),
              ),
            ))
        .toSet();
  }

  Iterable<String> getAutoCompleteOptions(TextEditingValue value) {
    if (value.text.isEmpty) {
      setState(_resetDisplayedCameras);
      return [];
    }
    return _neighbourhoods.map((n) => n.name).where(
      (name) {
        return name.toLowerCase().contains(value.text.trim().toLowerCase());
      },
    );
  }

  Future<void> _downloadAll() async {
    _darkMapStyle = await rootBundle.loadString('assets/dark_mode.json');
    _prefs = await SharedPreferences.getInstance();
    /*
    _allCameras = await DownloadService.downloadCameras();
    _allCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));

    _neighbourhoods = await DownloadService.downloadNeighbourhoods();

    for (var camera in _allCameras) {
      for (var neighbourhood in _neighbourhoods) {
        if (neighbourhood.containsCamera(camera)) {
          camera.neighbourhood = neighbourhood.name;
        }
      }
    }
    _readSharedPrefs();
    _resetDisplayedCameras();
    return _allCameras;
    */
  }

  void _closeSearchBar() {
    _resetDisplayedCameras();
    _textEditingController.clear();
    setState(() {
      searchMode = SearchMode.none;
      _isFiltered = false;
    });
  }

  void _showRandomCamera() {
    var visibleCameras =
        _allCameras.where((camera) => camera.isVisible).toList();
    if (visibleCameras.isNotEmpty) {
      _showCameras([visibleCameras[Random().nextInt(_allCameras.length)]]);
    }
  }

  void _favouriteOptionClicked() {
    if (_selectedCameras.isEmpty) {
      _filterDisplayedCameras((camera) => camera.isFavourite);
    } else {
      _favouriteSelectedCameras();
    }
  }

  void _favouriteSelectedCameras() {
    var allFave = _selectedCameras.every((camera) => camera.isFavourite);
    for (var element in _selectedCameras) {
      element.isFavourite = !allFave;
    }
    _writeSharedPrefs();
  }

  void _filterDisplayedCameras(bool Function(Camera) predicate) {
    if (_isFiltered) {
      _resetDisplayedCameras();
    } else {
      _displayedCameras = _allCameras.where(predicate).toList();
      _isFiltered = true;
    }
  }

  void _filterDisplayedCamerasByNeighbourhood(String query) {
    setState(() {
      _displayedCameras = _allCameras.where((cam) {
        return cam.isVisible &&
            cam.neighbourhood.toLowerCase().contains(query.toLowerCase());
      }).toList();
      _isFiltered = true;
    });
  }

  void _filterDisplayedCamerasWithString(String query) {
    List<Camera> result = _allCameras.where((cam) => cam.isVisible).toList();
    String q = query.toLowerCase();
    if (q.startsWith('f:')) {
      q = q.substring(2).trim();
      result.removeWhere((camera) => !camera.isFavourite);
    } else if (q.startsWith('h:')) {
      q = q.substring(2).trim();
      result.removeWhere((camera) => camera.isVisible);
    }
    result.removeWhere((camera) => !camera.name.toLowerCase().contains(q));
    setState(() {
      _displayedCameras = result;
      _isFiltered = true;
    });
  }

  BitmapDescriptor _getMarkerIcon(Camera camera) {
    if (_selectedCameras.contains(camera)) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    if (camera.isFavourite) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
    return BitmapDescriptor.defaultMarker;
  }

  void _hideOptionClicked() {
    if (_selectedCameras.isEmpty) {
      _filterDisplayedCameras((camera) => !camera.isVisible);
    } else {
      _hideSelectedCameras();
    }
  }

  void _hideSelectedCameras() {
    var allHidden = _selectedCameras.every((camera) => !camera.isVisible);
    for (var camera in _selectedCameras) {
      camera.isVisible = !allHidden;
    }
    _writeSharedPrefs();
  }

  void _resetDisplayedCameras() {
    _selectedCameras.clear();
    _displayedCameras = _allCameras.where((cam) => cam.isVisible).toList();
    _isFiltered = false;
  }

  /// Adds/removes a [Camera] to/from the selected camera list.
  void _selectCamera(Camera camera) {
    setState(() {
      if (_selectedCameras.contains(camera)) {
        _selectedCameras.remove(camera);
      } else {
        _selectedCameras.add(camera);
      }
    });
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

  void _writeSharedPrefs() {
    for (var camera in _allCameras) {
      _prefs?.setBool('${camera.sortableName}.isFavourite', camera.isFavourite);
      _prefs?.setBool('${camera.sortableName}.isVisible', camera.isVisible);
    }
  }

  void _readSharedPrefs() {
    for (var c in _allCameras) {
      c.isFavourite = _prefs?.getBool('${c.sortableName}.isFavourite') ?? false;
      c.isVisible = _prefs?.getBool('${c.sortableName}.isVisible') ?? true;
    }
  }
}

enum SearchMode { none, camera, neighbourhood }

class FilterTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final void Function() onBackPressed;
  final void Function() onClearPressed;

  const FilterTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onBackPressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      decoration: InputDecoration(
        icon: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onClearPressed.call();
                },
              )
            : null,
        hintText: hintText,
      ),
    );
  }
}

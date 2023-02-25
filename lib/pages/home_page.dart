import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

import '../camera_model.dart';
import '../entities/bilingual_object.dart';
import '../entities/camera.dart';
import '../entities/location.dart';
import '../entities/neighbourhood.dart';
import 'camera_page.dart';

Future<List<Camera>> _downloadCameraList() async {
  var url = Uri.parse('https://traffic.ottawa.ca/beta/camera_list');
  return compute(_parseCameraJson, await http.read(url));
}

Future<List<Neighbourhood>> _downloadNeighbourhoodList() async {
  var url = Uri.parse(
      'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson');
  return compute(_parseNeighbourhoodJson, await http.read(url));
}

Future<Position> _getCurrentLocation() async {
  // Test if location services are enabled.
  bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isLocationEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are denied');
    }
  }

  return await Geolocator.getLastKnownPosition() ??
      await Geolocator.getCurrentPosition();
}

List<Camera> _parseCameraJson(String jsonString) {
  List jsonArray = json.decode(jsonString);
  return jsonArray.map((json) => Camera.fromJson(json)).toList();
}

List<Neighbourhood> _parseNeighbourhoodJson(String jsonString) {
  List jsonArray = json.decode(jsonString)['features'];
  return jsonArray.map((json) => Neighbourhood.fromJson(json)).toList();
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CameraModel cameraModel = CameraModel([]);
  Future<List<Camera>>? future;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final List<int> _positions = [];
  final int _maxCameras = 8;
  bool _showList = true;
  bool _isFiltered = false;
  bool _showSearchBox = false;
  bool _sortedByName = true;
  int _selectedIndex = -1;
  SharedPreferences? _prefs;
  List<Camera> _allCameras = [];
  List<Camera> _displayedCameras = [];
  List<Camera> _selectedCameras = [];
  List<Neighbourhood> _neighbourhoods = [];

  @override
  void initState() {
    future = _downloadAll();
    future?.then((cameras) => cameraModel = CameraModel(cameras));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: getTitleBar(),
        actions: getAppBarActions(),
        backgroundColor: _selectedCameras.isEmpty ? null : Colors.blue,
      ),
      body: FutureBuilder<List<Camera>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(BilingualObject.translate('error')));
          } else if (snapshot.hasData) {
            return IndexedStack(
              index: _showList ? 0 : 1,
              children: [
                getListView(),
                getMapView(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget getTitleBar() {
    if (!_showSearchBox || _selectedCameras.isNotEmpty) {
      return GestureDetector(
        child: Text(_selectedCameras.isEmpty
            ? BilingualObject.appName
            : '${_selectedCameras.length} selected'),
        onTap: () => _moveToListPosition(0),
      );
    } else {
      return TextField(
        controller: _textEditingController,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: TextInputAction.done,
        onChanged: _filterDisplayedCamerasWithString,
        decoration: InputDecoration(
            icon: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _resetDisplayedCameras();
                _textEditingController.clear();
                setState(() {
                  _showSearchBox = false;
                  _isFiltered = false;
                });
              },
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _textEditingController.clear();
                  _filterDisplayedCamerasWithString('');
                });
              },
            ),
            hintText: Intl.plural(
              _displayedCameras.length,
              one: sprintf(BilingualObject.translate('searchCamera'),
                  [_displayedCameras.length]),
              other: sprintf(BilingualObject.translate('searchCameras'),
                  [_displayedCameras.length]),
              name: 'displayedCamerasCounter',
              args: [_displayedCameras.length],
              desc: 'Number of displayed cameras.',
            )),
      );
    }
  }

  PopupMenuItem convertToOverflowAction(IconButton iconButton) {
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

  List<Widget> getAppBarActions() {
    var clear = Visibility(
      visible: _selectedCameras.isNotEmpty,
      child: IconButton(
        tooltip: BilingualObject.translate('clear'),
        onPressed: () => setState(_selectedCameras.clear),
        icon: const Icon(Icons.close),
      ),
    );
    var search = Visibility(
      visible: _selectedCameras.isEmpty && !_showSearchBox,
      child: IconButton(
        tooltip: BilingualObject.translate('search'),
        onPressed: () {
          setState(() {
            if (_showSearchBox) {
              _resetDisplayedCameras();
            }
            _showSearchBox = !_showSearchBox;
          });
        },
        icon: const Icon(Icons.search),
      ),
    );
    var showCameras = Visibility(
      visible:
          _selectedCameras.isNotEmpty && _selectedCameras.length <= _maxCameras,
      child: IconButton(
        tooltip: BilingualObject.translate('showCameras'),
        onPressed: () => _showCameras(_selectedCameras),
        icon: const Icon(Icons.camera_alt),
      ),
    );
    var switchView = Visibility(
      visible: defaultTargetPlatform != TargetPlatform.windows || kIsWeb,
      child: IconButton(
        onPressed: (() => setState(() => _showList = !_showList)),
        icon: Icon(_showList ? Icons.map : Icons.list),
        tooltip: BilingualObject.translate(_showList ? 'map' : 'list'),
      ),
    );
    var sort = Visibility(
      visible: _selectedCameras.isEmpty && _showList && !_showSearchBox,
      child: PopupMenuButton(
        position: PopupMenuPosition.under,
        itemBuilder: (context) {
          return getSortingOptions();
        },
        icon: const Icon(Icons.sort),
        tooltip: BilingualObject.translate('sort'),
      ),
    );
    var favourite = Visibility(
      child: IconButton(
        onPressed: () => setState(_favouriteOptionClicked),
        icon: getFavouriteIcon(),
        tooltip: getFavouriteTooltip(),
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
        tooltip: BilingualObject.translate('selectAll'),
      ),
    );
    var random = Visibility(
      visible: _selectedCameras.isEmpty,
      child: IconButton(
        onPressed: showRandomCamera,
        icon: const Icon(Icons.casino),
        tooltip: BilingualObject.translate('random'),
      ),
    );
    var shuffle = Visibility(
      visible: _selectedCameras.isEmpty,
      child: IconButton(
        onPressed: () {
          if (_allCameras.isEmpty) return;
          _showCameras(
              _allCameras.where((element) => !element.isVisible).toList(),
              shuffle: true);
        },
        icon: const Icon(Icons.shuffle),
        tooltip: BilingualObject.translate('shuffle'),
      ),
    );
    var about = Visibility(
      visible: _selectedCameras.isEmpty,
      child: IconButton(
        tooltip: BilingualObject.translate('about'),
        icon: const Icon(Icons.info),
        onPressed: () {
          showAboutDialog(context: context, applicationVersion: '1.0.0+1');
        },
      ),
    );

    List<Visibility> actions = [
      clear,
      search,
      showCameras,
      switchView,
      sort,
      favourite,
      hidden,
      selectAll,
      random,
      shuffle,
      about,
    ];
    List<Visibility> visibleActions =
        actions.where((action) => action.visible).toList();
    List<Visibility> overflowActions = [];
    // the number of 48-width buttons that can fit in 1/4 the width of the window
    int maxActions = (MediaQuery.of(context).size.width / 4 / 48).floor();
    if (visibleActions.length > maxActions) {
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
              tooltip: BilingualObject.translate('more'),
              position: PopupMenuPosition.under,
              itemBuilder: (context) {
                return overflowActions
                    .map((visibility) =>
                        convertToOverflowAction(visibility.child as IconButton))
                    .toList();
              }),
        ),
      );
    }
    return visibleActions;
  }

  void showRandomCamera() {
    var visibleCameras =
        _allCameras.where((camera) => camera.isVisible).toList();
    if (visibleCameras.isNotEmpty) {
      _showCameras([visibleCameras[Random().nextInt(_allCameras.length)]]);
    }
  }

  String getFavouriteTooltip() {
    String result = '';
    if (_selectedCameras.isEmpty) {
      result = 'favourites';
    } else if (_selectedCameras.every((camera) => camera.isFavourite)) {
      result = 'unfavourite';
    } else {
      result = 'favourite';
    }
    return BilingualObject.translate(result);
  }

  String getHiddenTooltip() {
    String result = '';
    if (_selectedCameras.isEmpty) {
      result = 'hidden';
    } else if (_selectedCameras.every((camera) => camera.isVisible)) {
      result = 'unhide';
    } else {
      result = 'hide';
    }
    return BilingualObject.translate(result);
  }

  Icon getFavouriteIcon() {
    if (_selectedCameras.isEmpty ||
        _selectedCameras.any((camera) => !camera.isFavourite)) {
      return const Icon(Icons.star);
    }
    return const Icon(Icons.star_border);
  }

  Icon getHiddenIcon() {
    if (_selectedCameras.isEmpty || _selectedCameras.any((c) => !c.isVisible)) {
      return const Icon(Icons.visibility_off);
    }
    return const Icon(Icons.visibility);
  }

  List<PopupMenuItem> getSortingOptions() {
    return [
      PopupMenuItem(
        onTap: _sortCamerasByName,
        child: Text(BilingualObject.translate('sortName')),
      ),
      PopupMenuItem(
        onTap: _sortCamerasByDistance,
        child: Text(BilingualObject.translate('sortDistance')),
      ),
      PopupMenuItem(
        onTap: _sortCamerasByNeighbourhood,
        child: Text(BilingualObject.translate('sortNeighbourhood')),
      ),
    ];
  }

  Widget getListView() {
    return Row(children: [
      if (!_isFiltered && _sortedByName)
        Flexible(
          flex: 0,
          child: getSectionIndex(),
        ),
      Expanded(
        child: getListViewBuilder(),
      ),
    ]);
  }

  Widget getSectionIndex() {
    List<Widget> result = [];
    Set<String> indices = {};
    for (int i = 0; i < _displayedCameras.length; i++) {
      var letter = _displayedCameras[i].sortableName[0];
      if (!indices.contains(letter)) {
        indices.add(letter);
        if (!_positions.contains(i)) {
          _positions.add(i);
        }
        result.add(
          Expanded(
            child: Container(
              color: Colors.transparent,
              width: 20,
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                      fontSize: 12,
                      color: _selectedIndex == i ? Colors.blue : null),
                ),
              ),
            ),
          ),
        );
      }
    }
    return GestureDetector(
      child: Column(children: result),
      onTapDown: (details) => _scrollFromPointer(details.globalPosition.dy),
      onTapUp: (details) => _resetSelectedIndex(),
      onVerticalDragUpdate: (details) =>
          _scrollFromPointer(details.globalPosition.dy),
      onVerticalDragEnd: (details) => _resetSelectedIndex(),
    );
  }

  void _resetSelectedIndex() {
    setState(() => _selectedIndex = -1);
  }

  void _scrollFromPointer(double yPosition) {
    var topSection =
        MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
    var yPos = yPosition - topSection;
    var sectionIndexHeight = MediaQuery.of(context).size.height - topSection;
    int listIndex = (yPos / sectionIndexHeight * _positions.length).toInt();

    setState(() {
      _moveToListPosition(_positions[listIndex]);
      _selectedIndex = _positions[listIndex];
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
          return getCameraCountListTile();
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
            _displayedCameras[i].isFavourite ? Icons.star : Icons.star_border),
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

  Widget getCameraCountListTile() {
    return ListTile(
      title: Center(
        child: Text(
          Intl.plural(
            _displayedCameras.length,
            one:
                '${_displayedCameras.length} ${BilingualObject.translate('camera')}',
            other:
                '${_displayedCameras.length} ${BilingualObject.translate('cameras')}',
            name: 'displayedCamerasCounter',
            args: [_displayedCameras.length],
            desc: 'Number of displayed cameras.',
          ),
        ),
      ),
    );
  }

  Widget getMapView() {
    LatLngBounds? bounds;
    LatLng initialCameraPosition = const LatLng(45.4, -75.7);
    if (_displayedCameras.isNotEmpty) {
      var minLat = _displayedCameras[0].location.lat;
      var maxLat = _displayedCameras[0].location.lat;
      var minLon = _displayedCameras[0].location.lon;
      var maxLon = _displayedCameras[0].location.lon;
      for (var camera in _displayedCameras) {
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
    return GoogleMap(
        cameraTargetBounds: CameraTargetBounds(bounds),
        initialCameraPosition: CameraPosition(target: initialCameraPosition),
        minMaxZoomPreference: const MinMaxZoomPreference(9, 16),
        markers: getMapMarkers(),
        onMapCreated: (GoogleMapController controller) {
          if (Theme.of(context).brightness == Brightness.dark) {
            rootBundle
                .loadString('assets/dark_mode.json')
                .then(controller.setMapStyle);
          }
        });
  }

  Set<Marker> getMapMarkers() {
    return _displayedCameras
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

  /*Widget getSearchBox() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          setState(_resetDisplayedCameras);
          return const Iterable<String>.empty();
        }
        return _neighbourhoods.map((neighbourhood) => neighbourhood.name).where(
            (neighbourhoodName) => neighbourhoodName
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        setState(() {
          _filterDisplayedCameras((cam) => cam.neighbourhood == selection);
        });
      },
    );
  }*/

  Future<List<Camera>> _downloadAll() async {
    if (_allCameras.isNotEmpty) return _allCameras;

    _prefs = await SharedPreferences.getInstance();

    _allCameras = await _downloadCameraList();
    _allCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));

    _neighbourhoods = await _downloadNeighbourhoodList();

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

  void _filterDisplayedCamerasWithString(String query) {
    List<Camera> result =
        _allCameras.where((camera) => camera.isVisible).toList();
    String q = query.toLowerCase();
    if (q.startsWith('f:')) {
      q = q.substring(2).trim();
      result.removeWhere((camera) => !camera.isFavourite);
    } else if (q.startsWith('h:')) {
      q = q.substring(2).trim();
      result.removeWhere((camera) => camera.isVisible);
    } else if (q.startsWith('n:')) {
      q = q.substring(2).trim();
      result.removeWhere((cam) => !cam.neighbourhood.toLowerCase().contains(q));
    } else {
      result.removeWhere((camera) => !camera.name.toLowerCase().contains(q));
    }
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
    // if any of the selected cameras is not visible, hide the selected cameras
    var anyNotVisible = _selectedCameras.any((camera) => !camera.isVisible);
    for (var camera in _selectedCameras) {
      camera.isVisible = !anyNotVisible;
    }
    _writeSharedPrefs();
  }

  void _readSharedPrefs() {
    for (var c in _allCameras) {
      c.isFavourite = _prefs?.getBool('${c.sortableName}.isFavourite') ?? false;
      c.isVisible = _prefs?.getBool('${c.sortableName}.isVisible') ?? true;
    }
  }

  void _resetDisplayedCameras() {
    _selectedCameras.clear();
    _displayedCameras = _allCameras.where((cam) => cam.isVisible).toList();
    _isFiltered = false;
  }

  /// Adds/removes a [Camera] to/from the selected camera list.
  /// Returns true if the [Camera] was added, or false if it was removed.
  bool _selectCamera(Camera camera) {
    if (_selectedCameras.contains(camera)) {
      _selectedCameras.remove(camera);
      return false;
    }
    _selectedCameras.add(camera);
    return true;
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

  void _sortCamerasByName() {
    _displayedCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
    setState(() => _sortedByName = true);
  }

  Future<void> _sortCamerasByDistance() async {
    var position = await _getCurrentLocation();
    var location = Location(lat: position.latitude, lon: position.longitude);
    _displayedCameras.sort((a, b) {
      int result = location
          .distanceTo(a.location)
          .compareTo(location.distanceTo(b.location));
      if (result == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
    setState(() => _sortedByName = false);
  }

  void _sortCamerasByNeighbourhood() {
    _displayedCameras.sort((a, b) {
      int result = a.neighbourhood.compareTo(b.neighbourhood);
      if (a.neighbourhood.compareTo(b.neighbourhood) == 0) {
        return a.sortableName.compareTo(b.sortableName);
      }
      return result;
    });
    setState(() => _sortedByName = false);
  }

  void _writeSharedPrefs() {
    for (var camera in _displayedCameras) {
      _prefs?.setBool('${camera.sortableName}.isFavourite', camera.isFavourite);
      _prefs?.setBool('${camera.sortableName}.isVisible', camera.isVisible);
    }
  }
}

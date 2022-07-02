import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';

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
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
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
  var _showList = true;
  var _stackIndex = 0;
  var _sortByDistance = false;
  SharedPreferences? prefs;
  List<Camera> allCameras = [];
  List<Camera> displayedCameras = [];
  List<Camera> selectedCameras = [];
  List<Neighbourhood> neighbourhoods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(BilingualObject.appName),
        actions: getAppBarActions(),
      ),
      body: FutureBuilder<List<Camera>>(
        future: _downloadAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('An error has occurred.'));
          } else if (snapshot.hasData) {
            return Column(
              children: [
                /*Stack(
                  children: [
                    const Visibility(
                      child: Text('Search by neighbourhood'),
                    ),
                    Visibility(visible: true, child: getSearchBox())
                  ],
                ),*/
                Expanded(
                  child: IndexedStack(
                    index: _stackIndex,
                    children: [
                      getListView(),
                      Center(
                        child: getMapView(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  PopupMenuItem convertToOverflowAction(Visibility visibility) {
    var iconButton = visibility.child as IconButton;
    return PopupMenuItem(
      child: ListTile(
        leading: iconButton.icon,
        title: Text(iconButton.tooltip ?? ''),
        onTap: iconButton.onPressed,
      ),
    );
  }

  List<Widget> getAppBarActions() {
    List<Widget> actions = [
      // Number of selected cameras
      Visibility(
        visible: selectedCameras.isNotEmpty,
        child: Center(
          child: Text('${selectedCameras.length}'),
        ),
      ),
      // Clear selected cameras
      Visibility(
        visible: selectedCameras.isNotEmpty,
        child: IconButton(
          tooltip: 'Clear',
          onPressed: () {
            setState(() {
              selectedCameras.clear();
              _resetDisplayedCameras();
            });
          },
          icon: const Icon(Icons.close),
        ),
      ),
      // Show selected cameras
      Visibility(
        visible: selectedCameras.isNotEmpty && selectedCameras.length < 5,
        child: IconButton(
          tooltip: 'Show',
          onPressed: () {
            _showCameras(selectedCameras);
          },
          icon: const Icon(Icons.camera_alt),
        ),
      ),
      // Sort by distance/name
      Visibility(
        visible: selectedCameras.isEmpty && _showList,
        child: IconButton(
          onPressed: () {
            _sortCameras().then((value) => setState(() {}));
          },
          icon: const Icon(Icons.sort),
          tooltip: 'Sort by ${_sortByDistance ? 'name' : 'distance'}',
        ),
      ),
      // Show map/list
      Visibility(
        child: IconButton(
          onPressed: (() {
            setState(() {
              _showList = !_showList;
              _stackIndex = _showList ? 0 : 1;
            });
          }),
          icon: Icon(_showList ? Icons.map : Icons.list),
          tooltip: _showList ? 'Map' : 'List',
        ),
      ),
      // Favourite cameras
      Visibility(
        child: IconButton(
          onPressed: () {
            setState(_favouriteOptionClicked);
          },
          icon: const Icon(Icons.favorite),
          tooltip: 'Favourites',
        ),
      ),
      // Hidden cameras
      Visibility(
        child: IconButton(
          onPressed: () {
            setState(_hideOptionClicked);
          },
          icon: const Icon(Icons.visibility_off),
          tooltip: 'Hidden',
        ),
      ),
      // Select all cameras
      Visibility(
        visible: selectedCameras.isEmpty ||
            selectedCameras.length < displayedCameras.length,
        child: IconButton(
          onPressed: () {
            setState(() {
              selectedCameras = List.from(displayedCameras);
            });
          },
          icon: const Icon(Icons.select_all),
          tooltip: 'Select all',
        ),
      ),
      // Show random camera
      Visibility(
        visible: selectedCameras.isEmpty,
        child: IconButton(
          onPressed: () {
            if (allCameras.isEmpty) return;
            _showCameras([
              allCameras
                  .where((element) => !element.isHidden)
                  .toList()[Random().nextInt(displayedCameras.length)]
            ]);
          },
          icon: const Icon(Icons.casino),
          tooltip: 'Random',
        ),
      ),
      // Shuffle cameras
      Visibility(
        visible: selectedCameras.isEmpty,
        child: IconButton(
          onPressed: () {
            if (allCameras.isEmpty) return;
            _showCameras(
                allCameras.where((element) => !element.isHidden).toList(),
                shuffle: true);
          },
          icon: const Icon(Icons.shuffle),
          tooltip: 'Shuffle',
        ),
      ),
      // About StreetCams
      Visibility(
        child: IconButton(
          tooltip: 'About',
          icon: const Icon(Icons.info),
          onPressed: () {
            showAboutDialog(context: context, applicationVersion: '1.0.0+1');
          },
        ),
      ),
    ];
    var maxActions = (MediaQuery.of(context).size.width * .75 / 48).floor();
    if (actions.length > maxActions) {
      List<Widget> overflowActions = actions
          .sublist(maxActions, actions.length)
          .where((element) => (element as Visibility).visible)
          .toList();

      actions = actions.sublist(0, maxActions);
      actions.add(PopupMenuButton(
        tooltip: 'More',
        position: PopupMenuPosition.under,
        itemBuilder: (context) {
          return overflowActions
              .map((action) => convertToOverflowAction(action as Visibility))
              .toList();
        },
      ));
    }
    return actions;
  }

  Widget getListView() {
    return ListView.builder(
      itemCount: displayedCameras.length + 1,
      itemBuilder: (context, i) {
        if (i == displayedCameras.length) {
          return ListTile(
            title: Center(
              child: Text(
                Intl.plural(
                  displayedCameras.length,
                  one: '${displayedCameras.length} camera',
                  other: '${displayedCameras.length} cameras',
                  name: 'displayedCamerasCounter',
                  args: [displayedCameras.length],
                  desc: 'Number of displayed cameras',
                ),
              ),
            ),
          );
        }
        return ListTile(
          tileColor: selectedCameras.contains(displayedCameras[i])
              ? Colors.blue
              : null,
          dense: true,
          title: Text(
            displayedCameras[i].name,
            style: const TextStyle(fontSize: 16),
          ),
          subtitle: displayedCameras[i].neighbourhood.isNotEmpty
              ? Text(displayedCameras[i].neighbourhood)
              : null,
          trailing: IconButton(
            icon: Icon(displayedCameras[i].isFavourite
                ? Icons.favorite
                : Icons.favorite_border),
            color: displayedCameras[i].isFavourite ? Colors.red : null,
            onPressed: () {
              setState(() {
                displayedCameras[i].isFavourite =
                    !displayedCameras[i].isFavourite;
                _writeSharedPrefs();
              });
            },
          ),
          onTap: () {
            if (selectedCameras.isEmpty) {
              _showCameras([displayedCameras[i]]);
            } else {
              setState(() {
                _selectCamera(displayedCameras[i]);
              });
            }
          },
          onLongPress: () {
            setState(() {
              _selectCamera(displayedCameras[i]);
            });
          },
        );
      },
    );
  }

  Widget getMapView() {
    Completer<GoogleMapController> completer = Completer();
    const CameraPosition cameraPosition = CameraPosition(
      target: LatLng(45.4, -75.7),
    );

    LatLngBounds? bounds;
    CameraUpdate? cameraUpdate;
    if (displayedCameras.isNotEmpty) {
      var minLat = displayedCameras[0].location.lat;
      var maxLat = displayedCameras[0].location.lat;
      var minLon = displayedCameras[0].location.lon;
      var maxLon = displayedCameras[0].location.lon;
      for (var camera in displayedCameras) {
        minLat = min(minLat, camera.location.lat);
        maxLat = max(maxLat, camera.location.lat);
        minLon = min(minLon, camera.location.lon);
        maxLon = max(maxLon, camera.location.lon);
      }
      bounds = LatLngBounds(
          southwest: LatLng(minLat, minLon), northeast: LatLng(maxLat, maxLon));
      cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 20);
    }

    return GoogleMap(
        cameraTargetBounds: CameraTargetBounds(bounds),
        initialCameraPosition: cameraPosition,
        minMaxZoomPreference: const MinMaxZoomPreference(9, 16),
        markers: displayedCameras
            .map((camera) => Marker(
                  icon: _getMarkerIcon(camera),
                  markerId: MarkerId(camera.id.toString()),
                  position: LatLng(camera.location.lat, camera.location.lon),
                  infoWindow: InfoWindow(
                    title: camera.name,
                    onTap: () {
                      _showCameras([camera]);
                    },
                  ),
                ))
            .toSet(),
        onMapCreated: (GoogleMapController controller) {
          if (cameraUpdate != null) {
            controller.animateCamera(cameraUpdate);
          }
          completer.complete(controller);
        });
  }

  Widget getSearchBox() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          setState(() {
            _resetDisplayedCameras();
          });
          return const Iterable<String>.empty();
        }
        return neighbourhoods.map((neighbourhood) => neighbourhood.name).where(
            (neighbourhoodName) => neighbourhoodName
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        setState(() {
          _filterDisplayedCameras(
              (camera) => camera.neighbourhood == selection);
        });
      },
    );
  }

  Future<List<Camera>> _downloadAll() async {
    if (allCameras.isNotEmpty) return allCameras;

    prefs = await SharedPreferences.getInstance();

    allCameras = await _downloadCameraList();
    allCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));

    neighbourhoods = await _downloadNeighbourhoodList();

    for (var camera in allCameras) {
      for (var neighbourhood in neighbourhoods) {
        if (neighbourhood.containsCamera(camera)) {
          camera.neighbourhood = neighbourhood.name;
        }
      }
    }
    _readSharedPrefs();
    _resetDisplayedCameras();
    return allCameras;
  }

  void _favouriteOptionClicked() {
    if (selectedCameras.isEmpty) {
      _filterDisplayedCameras((camera) => camera.isFavourite);
    } else {
      _favouriteSelectedCameras();
    }
  }

  void _favouriteSelectedCameras() {
    var allFave = selectedCameras.every((camera) => camera.isFavourite);
    for (var element in selectedCameras) {
      element.isFavourite = !allFave;
    }
    _writeSharedPrefs();
  }

  void _filterDisplayedCameras(bool Function(Camera) predicate) {
    // If no cameras are displayed, or every displayed camera satisfies the
    // predicate, reset the displayed cameras.
    if (displayedCameras.isEmpty || displayedCameras.every(predicate)) {
      return _resetDisplayedCameras();
    }
    displayedCameras = allCameras.where(predicate).toList();
  }

  BitmapDescriptor _getMarkerIcon(Camera camera) {
    if (selectedCameras.contains(camera)) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    if (camera.isFavourite) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    }
    return BitmapDescriptor.defaultMarker;
  }

  void _hideOptionClicked() {
    if (selectedCameras.isEmpty) {
      _filterDisplayedCameras((camera) => camera.isHidden);
    } else {
      _hideSelectedCameras();
    }
  }

  void _hideSelectedCameras() {
    var allHidden = selectedCameras.every((camera) => camera.isHidden);
    for (var camera in selectedCameras) {
      camera.isHidden = !allHidden;
    }
    _writeSharedPrefs();
  }

  void _readSharedPrefs() {
    for (var camera in allCameras) {
      camera.isFavourite =
          prefs?.getBool('${camera.sortableName}.isFavourite') ?? false;
      camera.isHidden =
          prefs?.getBool('${camera.sortableName}.isHidden') ?? false;
    }
  }

  void _resetDisplayedCameras() {
    displayedCameras = allCameras.where((camera) => !camera.isHidden).toList();
  }

  /// Adds/removes a [Camera] to/from the selected camera list.
  /// Returns true if the [Camera] was added, or false if it was removed.
  bool _selectCamera(Camera camera) {
    if (selectedCameras.contains(camera)) {
      selectedCameras.remove(camera);
      return false;
    }
    selectedCameras.add(camera);
    return true;
  }

  void _showCameras(List<Camera> cameras, {shuffle = false}) {
    if (cameras.isEmpty) return;
    Navigator.pushNamed(
      context,
      CameraPage.routeName,
      arguments: [cameras, shuffle],
    );
  }

  Future<void> _sortCameras() async {
    _sortByDistance = !_sortByDistance;
    if (_sortByDistance) {
      var position = await _getCurrentLocation();
      var location = Location(lat: position.latitude, lon: position.longitude);
      displayedCameras.sort((a, b) => location
          .distanceTo(a.location)
          .compareTo(location.distanceTo(b.location)));
    } else {
      displayedCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
    }
  }

  void _writeSharedPrefs() {
    for (var camera in displayedCameras) {
      prefs?.setBool('${camera.sortableName}.isFavourite', camera.isFavourite);
      prefs?.setBool('${camera.sortableName}.isHidden', camera.isHidden);
    }
  }
}

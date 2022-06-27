import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:streetcams_flutter/entities/bilingual_object.dart';

import '../entities/camera.dart';
import '../entities/location.dart';
import '../entities/neighbourhood.dart';
import 'camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = 'StreetCams';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var showList = true;
  var sortByDistance = false;
  List<Camera> allCameras = [];
  List<Camera> displayedCameras = [];
  List<Camera> selectedCameras = [];
  List<Neighbourhood> neighbourhoods = [];

  @override
  Widget build(BuildContext context) {
    _downloadNeighbourhoodList();
    return Scaffold(
      appBar: AppBar(
        title: Text(BilingualObject.appName),
        actions: getAppBarActions(),
      ),
      body: FutureBuilder<List<Camera>>(
        future: _downloadCameraList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('An error has occurred.'));
          } else if (snapshot.hasData) {
            if (allCameras.isEmpty) {
              allCameras = snapshot.data ?? displayedCameras;
              allCameras
                  .sort((a, b) => a.sortableName.compareTo(b.sortableName));
              _resetDisplayedCameras();
            }
            return Stack(
              children: [
                Visibility(visible: showList, child: getListView()),
                Visibility(visible: !showList, child: getMapView()),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  List<Widget> getAppBarActions() {
    return [
      Visibility(
        visible: selectedCameras.isNotEmpty,
        child: Center(
          child: Text(
              '${selectedCameras.length} camera${selectedCameras.length != 1 ? 's' : ''} selected'),
        ),
      ),
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
      Visibility(
        child: IconButton(
          onPressed: (() {
            setState(() {
              showList = !showList;
            });
          }),
          icon: const Icon(Icons.swap_horiz),
          tooltip: showList ? 'Map' : 'List',
        ),
      ),
      Visibility(
        visible: selectedCameras.isEmpty,
        child: IconButton(
          onPressed: () {
            _sortCameras().then((value) => setState(() {}));
          },
          icon: const Icon(Icons.sort),
          tooltip: 'Sort by ${sortByDistance ? 'name' : 'distance'}',
        ),
      ),
      Visibility(
        child: IconButton(
          onPressed: () {
            setState(_favouriteOptionClicked);
          },
          icon: const Icon(Icons.favorite),
          tooltip: 'Favourites',
        ),
      ),
      Visibility(
        child: IconButton(
          onPressed: () {
            setState(_hideOptionClicked);
          },
          icon: const Icon(Icons.visibility_off),
          tooltip: 'Hidden',
        ),
      ),
      Visibility(
        visible: selectedCameras.isEmpty,
        child: IconButton(
          onPressed: () {
            _showCameras(
                [displayedCameras[Random().nextInt(displayedCameras.length)]]);
          },
          icon: const Icon(Icons.casino),
          tooltip: 'Random',
        ),
      ),
      Visibility(
        visible: selectedCameras.isEmpty,
        child: IconButton(
          onPressed: () {
            _showCameras(
                allCameras.where((element) => !element.isHidden).toList(),
                shuffle: true);
          },
          icon: const Icon(Icons.shuffle),
          tooltip: 'Shuffle',
        ),
      ),
    ];
  }

  ListView getListView() {
    return ListView.builder(
      itemCount: displayedCameras.length,
      itemBuilder: (context, i) {
        return Container(
          color: selectedCameras.contains(displayedCameras[i])
              ? Colors.blue
              : Colors.transparent,
          child: ListTile(
            title: Text(displayedCameras[i].name),
            trailing: IconButton(
              icon: Icon(displayedCameras[i].isFavourite
                  ? Icons.favorite
                  : Icons.favorite_border),
              color: displayedCameras[i].isFavourite ? Colors.red : null,
              onPressed: () {
                setState(() {
                  displayedCameras[i].isFavourite =
                      !displayedCameras[i].isFavourite;
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
          ),
        );
      },
    );
  }

  Widget getMapView() {
    return const Center(child: Text('Map will go here!'));
  }

  Future<void> _sortCameras() async {
    sortByDistance = !sortByDistance;
    if (sortByDistance) {
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

      Position position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      var location = Location(lat: position.latitude, lon: position.longitude);
      displayedCameras.sort((a, b) => location
          .distanceTo(a.location)
          .compareTo(location.distanceTo(b.location)));
    } else {
      displayedCameras.sort((a, b) => a.sortableName.compareTo(b.sortableName));
    }
  }

  void _favouriteOptionClicked() {
    if (selectedCameras.isEmpty) {
      _filterDisplayedCameras((camera) => camera.isFavourite);
    } else {
      _favouriteSelectedCameras();
    }
  }

  void _favouriteSelectedCameras() {
    var allFave = _allTrue(selectedCameras, (camera) => camera.isFavourite);
    for (var element in selectedCameras) {
      element.isFavourite = allFave ? !element.isFavourite : true;
    }
  }

  void _hideOptionClicked() {
    if (selectedCameras.isEmpty) {
      _filterDisplayedCameras((camera) => camera.isHidden);
    } else {
      _hideSelectedCameras();
    }
  }

  void _hideSelectedCameras() {
    var allHidden = _allTrue(selectedCameras, (camera) => camera.isHidden);
    for (var camera in selectedCameras) {
      camera.isHidden = allHidden ? !camera.isHidden : true;
    }
  }

  bool _allTrue(List<Camera> list, bool Function(Camera) predicate) {
    return list.map(predicate).reduce((value, element) {
      return value && element;
    });
  }

  void _filterDisplayedCameras(bool Function(Camera) predicate) {
    if (displayedCameras.isEmpty || _allTrue(displayedCameras, predicate)) {
      return _resetDisplayedCameras();
    }
    displayedCameras = allCameras.where(predicate).toList();
  }

  void _resetDisplayedCameras() {
    displayedCameras = allCameras.where((camera) => !camera.isHidden).toList();
  }

  void _showCameras(List<Camera> cameras, {shuffle = false}) {
    if (cameras.isEmpty) return;
    Navigator.pushNamed(
      context,
      CameraPage.routeName,
      arguments: [cameras, shuffle],
    );
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
}

List<Camera> _parseCameraJson(String jsonString) {
  List<dynamic> jsonArray = json.decode(jsonString);
  return jsonArray.map((e) => Camera.fromJson(e)).toList();
}

List<Neighbourhood> _parseNeighbourhoodJson(String jsonString) {
  List<dynamic> jsonArray = json.decode(jsonString)['features'];
  return jsonArray.map((e) => Neighbourhood.fromJson(e)).toList();
}

Future<List<Camera>> _downloadCameraList() async {
  var url = Uri.parse('https://traffic.ottawa.ca/beta/camera_list');
  return compute(_parseCameraJson, await http.read(url));
}

Future<List<Neighbourhood>> _downloadNeighbourhoodList() async {
  var url = Uri.parse(
      'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson');
  return compute(_parseNeighbourhoodJson, await http.read(url));
}

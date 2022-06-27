import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'camera_page.dart';
import 'entities/camera.dart';
import 'entities/location.dart';
import 'entities/neighbourhood.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title = 'StreetCams';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
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

class _MyHomePageState extends State<MyHomePage> {
  var showList = true;
  var sortByDistance = false;
  List<Camera> allCameras = [];
  List<Camera> displayedCameras = [];
  List<Camera> selectedCameras = [];
  List<Neighbourhood> neighbourhoods = [];

  Future<void> sortCameras() async {
    sortByDistance = !sortByDistance;
    if (sortByDistance) {
      // Test if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      Position position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      var location = Location(lat: position.latitude, lon: position.longitude);
      displayedCameras.sort((a, b) => location
          .distanceTo(a.location)
          .compareTo(location.distanceTo(b.location)));
    } else {
      displayedCameras
          .sort((a, b) => a.getSortableName().compareTo(b.getSortableName()));
    }
    setState(() {});
  }

  List<Widget> getAppBarActions() {
    return [
      Visibility(
          visible: selectedCameras.isNotEmpty,
          child: Center(
            child: Text(
                '${selectedCameras.length} camera${selectedCameras.length != 1 ? 's' : ''} selected'),
          )),
      Visibility(
        visible: selectedCameras.isNotEmpty,
        child: IconButton(
            tooltip: 'Clear',
            onPressed: () {
              setState(() {
                selectedCameras.clear();
              });
            },
            icon: const Icon(Icons.close)),
      ),
      Visibility(
        visible: selectedCameras.isNotEmpty && selectedCameras.length < 5,
        child: IconButton(
            tooltip: 'Show',
            onPressed: () {
              _showCameras(selectedCameras);
            },
            icon: const Icon(Icons.camera_alt)),
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
      )),
      Visibility(
          visible: selectedCameras.isEmpty,
          child: IconButton(
            onPressed: sortCameras,
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by ${sortByDistance ? 'name' : 'distance'}',
          )),
      Visibility(
          child: IconButton(
        onPressed: favouriteOptionClicked,
        icon: const Icon(Icons.favorite),
        tooltip: 'Favourites',
      )),
      Visibility(
          child: IconButton(
        onPressed: hideOptionClicked,
        icon: const Icon(Icons.visibility_off),
        tooltip: 'Hidden',
      )),
      Visibility(
          visible: selectedCameras.isEmpty,
          child: IconButton(
            onPressed: () {
              _showCameras([
                displayedCameras[Random().nextInt(displayedCameras.length)]
              ]);
            },
            icon: const Icon(Icons.casino),
            tooltip: 'Random',
          )),
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
          )),
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
            title: Text(displayedCameras[i].getName()),
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
                _showCameras([
                  displayedCameras[i],
                ]);
              } else {
                setState(() {
                  selectCamera(displayedCameras[i]);
                });
              }
            },
            onLongPress: () {
              setState(() {
                selectCamera(displayedCameras[i]);
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(BilingualObject.getAppName()),
        actions: getAppBarActions(),
      ),
      body: FutureBuilder<List<Camera>>(
        future: _downloadCameraList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred.'),
            );
          } else if (snapshot.hasData) {
            if (allCameras.isEmpty) {
              allCameras = snapshot.data ?? displayedCameras;
              allCameras.sort(
                  (a, b) => a.getSortableName().compareTo(b.getSortableName()));
              resetDisplayedCameras();
            }
            return Stack(
              children: [
                Visibility(visible: showList, child: getListView()),
                Visibility(
                  visible: !showList,
                  child: const Center(child: Text('Map will go here!')),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void favouriteOptionClicked() {
    if (selectedCameras.isEmpty) {
      filterDisplayedCameras((p0) => p0.isFavourite);
    } else {
      favouriteSelectedCameras();
    }

    setState(() {});
  }

  void favouriteSelectedCameras() {
    var allFavourited =
        selectedCameras.map((e) => e.isFavourite).reduce((value, element) {
      return value && element;
    });
    if (allFavourited) {
      for (var element in selectedCameras) {
        element.isFavourite = !element.isFavourite;
      }
    } else {
      for (var element in selectedCameras) {
        element.isFavourite = true;
      }
    }
  }

  void hideOptionClicked() {
    if (selectedCameras.isEmpty) {
      filterDisplayedCameras((p0) => p0.isHidden);
    } else {
      hideSelectedCameras();
    }
    setState(() {});
  }

  void filterDisplayedCameras(bool Function(Camera) function) {
    if (displayedCameras.isEmpty) {
      resetDisplayedCameras();
      return;
    }
    var allHidden = displayedCameras.map(function).reduce((value, element) {
      return value && element;
    });
    if (allHidden) {
      resetDisplayedCameras();
      return;
    }
    displayedCameras = allCameras.where(function).toList();
  }

  void resetDisplayedCameras() {
    displayedCameras =
        allCameras.where((element) => !element.isHidden).toList();
  }

  void hideSelectedCameras() {
    var allHidden =
        selectedCameras.map((e) => e.isHidden).reduce((value, element) {
      return value && element;
    });
    if (allHidden) {
      for (var element in selectedCameras) {
        element.isHidden = !element.isHidden;
      }
    } else {
      for (var element in selectedCameras) {
        element.isHidden = true;
      }
    }
  }

  void _showCameras(List<Camera> cameras, {shuffle = false}) {
    if (cameras.isEmpty) return;
    Navigator.pushNamed(
      context,
      CameraPage.routeName,
      arguments: [cameras, shuffle],
    );
  }

  bool selectCamera(Camera camera) {
    if (selectedCameras.contains(camera)) {
      selectedCameras.remove(camera);
      return false;
    }
    selectedCameras.add(camera);
    return true;
  }
}

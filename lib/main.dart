import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:streetcams_flutter/neighbourhood.dart';

import 'camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreetCams',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'CA'),
        Locale('fr', 'CA'),
      ],
      home: const MyHomePage(title: 'StreetCams'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

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
  List<Camera> cameras = [];
  List<Neighbourhood> neighbourhoods = [];

  @override
  void initState() {
    _downloadCameraList().then((value) {
      neighbourhoods.sort((a, b) => a.getSortableName().compareTo(b.getSortableName()));
      setState(() {});
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Camera>>(
        future: _downloadCameraList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            cameras = snapshot.data ?? cameras;
            cameras.sort((a, b) => a.getSortableName().compareTo(b.getSortableName()));
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: cameras.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(cameras[i].getName()),
                  onTap: () {
                    setState(() {
                      _showCameras([cameras[i]]);
                    });
                  },
                  onLongPress: () {
                    print('long press');
                  },
                );
              },
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

  void _showCameras(List<Camera> cameras) {
    var camera = cameras[0];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          var url = 'https://traffic.ottawa.ca/beta/camera?id=${camera.num}&timems=${DateTime.now().millisecond}';
          return Scaffold(
            appBar: AppBar(
              title: Text(camera.nameEn),
            ),
            body: Center(
              child: Image.network(
                url,
                semanticLabel: camera.nameEn,
                width: MediaQuery.of(context).size.width - 20,
                height: MediaQuery.of(context).size.height - 20,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:streetcams_flutter/neighbourhood.dart';
import 'dart:convert';
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

List<Camera> parseCameraJson(String jsonString) {
  List<dynamic> jsonArray = json.decode(jsonString);
  return jsonArray.map((e) => Camera(e)) as List<Camera>;
}

List<Neighbourhood> parseNeighbourhoodJson(String jsonString) {
  List<dynamic> jsonArray = json.decode(jsonString)['features'];
  return jsonArray.map((e) => Neighbourhood(e)) as List<Neighbourhood>;
}

class _MyHomePageState extends State<MyHomePage> {
  List<Camera> cameras = [];
  List<Neighbourhood> neighbourhoods = [];

  @override
  void initState() {
    _download().then((value) {
      setState(() {});
    });
    super.initState();
  }

  Future<void> _download() async {
    var url = Uri.parse('https://traffic.ottawa.ca/beta/camera_list');
    compute(parseCameraJson, await http.read(url));
    cameras.sort((a, b) => a.getSortableName().compareTo(b.getSortableName()));

    url = Uri.parse(
        'https://services.arcgis.com/G6F8XLCl5KtAlZ2G/arcgis/rest/services/Gen_2_ONS_Boundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson');
    compute(parseNeighbourhoodJson, await http.read(url));
    neighbourhoods.sort((a, b) => a.getSortableName().compareTo(b.getSortableName()));
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
      body: ListView.builder(
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
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

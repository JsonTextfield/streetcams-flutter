import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:streetcams_flutter/camera_page.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';

import 'home_page.dart';

void main() {
  runApp(const StreetCamsApp());
}

class StreetCamsApp extends StatelessWidget {
  const StreetCamsApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: BilingualObject.getAppName(),
      home: const MyHomePage(),
      routes: {
        CameraPage.routeName: (context) => const CameraPage(),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'CA'),
        Locale('fr', 'CA'),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

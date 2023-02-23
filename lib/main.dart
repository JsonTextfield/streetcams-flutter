import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'entities/bilingual_object.dart';
import 'pages/camera_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const StreetCamsApp());
}

class StreetCamsApp extends StatelessWidget {
  const StreetCamsApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: BilingualObject.appName,
      home: const HomePage(),
      routes: {
        CameraPage.routeName: (context) => const CameraPage(),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(color: Colors.black),
        scaffoldBackgroundColor: Colors.black,
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
      debugShowCheckedModeBanner: false,
    );
  }
}

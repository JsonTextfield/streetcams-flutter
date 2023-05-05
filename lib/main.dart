import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart' as intl;

import 'blocs/camera_bloc.dart';
import 'constants.dart';
import 'entities/bilingual_object.dart';
import 'pages/camera_page.dart';
import 'pages/home_page.dart';

void main() {
  _setLocale();
  runApp(const StreetCamsApp());
}

void _setLocale() async {
  BilingualObject.locale = await intl.findSystemLocale();
}

class StreetCamsApp extends StatelessWidget {
  const StreetCamsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => CameraBloc()..add(CameraLoaded()),
        child: HomePage(),
      ),
      routes: {
        CameraPage.routeName: (context) => const CameraPage(),
      },
      theme: ThemeData.light(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          secondary: Constants.accentColour,
          primary: Constants.accentColour,
        ),
        appBarTheme: const AppBarTheme(color: Colors.black),
        scaffoldBackgroundColor: Colors.black,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
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

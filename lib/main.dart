import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/camera_bloc.dart';
import 'constants.dart';
import 'pages/camera_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const StreetCamsApp());
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
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          secondary: Constants.accentColour,
          primary: Constants.primaryColour,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Constants.accentColour),
        popupMenuTheme: PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          secondary: Constants.accentColour,
          primary: Constants.primaryColour,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        scaffoldBackgroundColor: Colors.black,
        popupMenuTheme: PopupMenuThemeData(
          color: Constants.darkMenuColour,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        menuTheme: MenuThemeData(
          style: MenuStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            )),
            backgroundColor:
                const MaterialStatePropertyAll<Color>(Constants.darkMenuColour),
          ),
        ),
        dialogBackgroundColor: Constants.darkMenuColour,
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

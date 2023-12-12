import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../blocs/camera_bloc.dart';
import '../constants.dart';
import 'pages/camera_page.dart';
import 'pages/home_page.dart';

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
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          secondary: Constants.accentColour,
          primary: Constants.primaryColour,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Constants.accentColour,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Constants.accentColour,
          ),
        ),
        popupMenuTheme: const PopupMenuThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        menuTheme: const MenuThemeData(
          style: MenuStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            )),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          secondary: Constants.accentColour,
          primary: Constants.primaryColour,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        scaffoldBackgroundColor: Colors.black,
        popupMenuTheme: const PopupMenuThemeData(
          color: Constants.darkMenuColour,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        menuTheme: const MenuThemeData(
          style: MenuStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            )),
            backgroundColor:
                MaterialStatePropertyAll<Color>(Constants.darkMenuColour),
          ),
        ),
        dialogBackgroundColor: Constants.darkMenuColour,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('en', 'CA'),
        Locale('fr', 'CA'),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}

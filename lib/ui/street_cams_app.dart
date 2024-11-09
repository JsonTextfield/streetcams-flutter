import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:streetcams_flutter/constants.dart';

import '../blocs/camera_bloc.dart';
import '../blocs/camera_state.dart';
import 'pages/camera_page.dart';
import 'pages/home_page.dart';

class StreetCamsApp extends StatelessWidget {
  const StreetCamsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraBloc()..add(CameraLoading()),
      child: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          return MaterialApp(
            home: HomePage(),
            routes: {
              CameraPage.routeName: (context) => const CameraPage(),
            },
            themeMode: state.theme,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Constants.accentColour,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              colorSchemeSeed: Constants.accentColour,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [
              Locale('en', 'CA'),
              Locale('fr', 'CA'),
            ],
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

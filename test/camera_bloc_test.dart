import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/entities/city.dart';

class MockLocaleListener extends Mock implements LocaleListener {}

class MockSharedPrefs extends Mock implements SharedPreferences {
  @override
  Future<bool> setString(String k, String v) async {
    return false;
  }

  @override
  Future<bool> setInt(String k, int v) async {
    return false;
  }

  @override
  Future<bool> setBool(String k, bool v) async {
    return false;
  }
}

void main() {
  MockLocaleListener? localeListener;
  MockSharedPrefs? sharedPrefs;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    EquatableConfig.stringify = true;
    localeListener = MockLocaleListener();
    sharedPrefs = MockSharedPrefs();
  });

  blocTest(
    'emits [] when nothing is added',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    expect: () => [],
  );

  blocTest(
    'emits 2 states (loading, loaded) when CameraLoading is added',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    seed: () => const CameraState(),
    act: (CameraBloc bloc) => bloc.add(CameraLoading()),
    wait: const Duration(seconds: 2),
    expect: () => [isA<CameraState>(), isA<CameraState>()],
  );

  blocTest(
    'test ChangeViewMode sets the state\'s view mode',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    seed: () => const CameraState(viewMode: ViewMode.map),
    act: (CameraBloc bloc) {
      expect(ViewMode.map, bloc.state.viewMode);
      bloc.add(ChangeViewMode(viewMode: ViewMode.list));
    },
    verify: (CameraBloc bloc) {
      expect(ViewMode.list, bloc.state.viewMode);
      return bloc;
    },
  );

  blocTest(
    'test ChangeTheme sets the state\'s theme',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    seed: () => const CameraState(theme: ThemeMode.dark),
    act: (CameraBloc bloc) {
      expect(ThemeMode.dark, bloc.state.theme);
      bloc.add(ChangeTheme(theme: ThemeMode.light));
    },
    verify: (CameraBloc bloc) {
      expect(ThemeMode.light, bloc.state.theme);
      return bloc;
    },
  );

  blocTest(
    'test SortCameras sets the state\'s sort mode',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    seed: () => const CameraState(sortMode: SortMode.distance),
    act: (CameraBloc bloc) {
      bloc.add(SortCameras(sortMode: SortMode.name));
    },
    verify: (CameraBloc bloc) {
      expect(SortMode.name, bloc.state.sortMode);
      return bloc;
    },
  );

  blocTest(
    'test ChangeCity sets the state\'s city',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    seed: () => const CameraState(city: City.toronto),
    act: (CameraBloc bloc) {
      bloc.add(ChangeCity(City.ottawa));
    },
    wait: const Duration(seconds: 2),
    verify: (CameraBloc bloc) {
      expect(City.ottawa, bloc.state.city);
      return bloc;
    },
  );
}

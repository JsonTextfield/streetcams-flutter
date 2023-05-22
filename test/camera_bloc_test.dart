import 'package:bloc_test/bloc_test.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';

class MockLocaleListener extends Mock implements LocaleListener {}

class MockSharedPrefs extends Mock implements SharedPreferences {}

void main() {
  MockLocaleListener? localeListener;
  MockSharedPrefs? sharedPrefs;
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
    'emits [] when CameraLoading is added',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    seed: () => const CameraState(),
    act: (CameraBloc bloc) => bloc.add(CameraLoading()),
    wait: const Duration(seconds: 2),
    expect: () => [],
  );

  blocTest(
    'emits [CameraState] when CameraLoaded is added',
    build: () => CameraBloc(
      localeListener: localeListener,
      prefs: sharedPrefs,
    ),
    act: (CameraBloc bloc) => bloc.add(CameraLoaded()),
    wait: const Duration(seconds: 2),
    expect: () => [isA<CameraState>()],
  );
}

import 'package:flutter/material.dart';

import '../blocs/camera_state.dart';
import '../entities/city.dart';

abstract class IPreferencesDataSource {
  Future<void> favourite(List<String> ids, bool value);

  Future<List<String>> getFavourites();

  Future<void> setVisibility(List<String> ids, bool value);

  Future<List<String>> getHidden();

  Future<void> setTheme(ThemeMode theme);

  Future<ThemeMode> getTheme();

  Future<void> setViewMode(ViewMode viewMode);

  Future<ViewMode> getViewMode();

  Future<void> setCity(City city);

  Future<City> getCity();
}

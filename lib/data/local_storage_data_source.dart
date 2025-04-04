import 'package:flutter/material.dart';

import '../blocs/camera_state.dart';
import '../entities/city.dart';

abstract class IPreferencesDataSource {
  void favourite(List<String> ids, bool value);

  Future<List<String>> getFavourites();

  void setVisibility(List<String> ids, bool value);

  Future<List<String>> getHidden();

  void setTheme(ThemeMode theme);

  Future<ThemeMode> getTheme();

  void setViewMode(ViewMode viewMode);

  Future<ViewMode> getViewMode();

  void setCity(City city);

  Future<City> getCity();
}

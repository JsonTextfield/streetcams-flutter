import 'package:flutter/src/material/app.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/data/local_storage_data_source.dart';
import 'package:streetcams_flutter/data/shared_preferences_data_source.dart';
import 'package:streetcams_flutter/entities/city.dart';

class FakeLocalStorageDataSource implements IPreferencesDataSource {
  final Map<String, Object> map = {};

  @override
  Future<void> favourite(Iterable<String> ids, bool value) async {
    map['favourites'] =
        value
            ? map['favourites'] ?? [] + ids.toList()
            : map['favourites'] ?? [] - ids;
  }

  @override
  Future<List<String>> getFavourites() async {
    return (map['favourites'] ?? <String>[]) as List<String>;
  }

  @override
  Future<void> setVisibility(Iterable<String> ids, bool value) async {
    map['hidden'] =
        value ? map['hidden'] ?? [] + ids.toList() : map['hidden'] ?? [] - ids;
  }

  @override
  Future<List<String>> getHidden() async {
    return (map['hidden'] ?? <String>[]) as List<String>;
  }

  @override
  Future<City> getCity() async {
    return (map['city'] ?? City.ottawa) as City;
  }

  @override
  Future<ThemeMode> getTheme() async {
    return (map['theme'] ?? ThemeMode.system) as ThemeMode;
  }

  @override
  Future<ViewMode> getViewMode() async {
    return (map['viewMode'] ?? ViewMode.list) as ViewMode;
  }

  @override
  Future<void> setCity(City city) async {
    map['city'] = city;
  }

  @override
  Future<void> setTheme(ThemeMode theme) async {
    map['theme'] = theme;
  }

  @override
  Future<void> setViewMode(ViewMode viewMode) async {
    map['viewMode'] = viewMode;
  }
}

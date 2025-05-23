import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/data/local_storage_data_source.dart';

import '../entities/city.dart';

class SharedPreferencesDataSource implements IPreferencesDataSource {
  final SharedPreferences _prefs;

  SharedPreferencesDataSource(this._prefs);

  @override
  Future<void> favourite(Iterable<String> ids, bool value) async {
    String key = 'favourites';
    List<String> currentFavourites = await getFavourites();
    List<String> newFavourites;
    if (value) {
      newFavourites = currentFavourites + ids.toSet().toList();
    } else {
      newFavourites = (currentFavourites - ids.toSet()).toList();
    }
    _prefs.setStringList(key, newFavourites);
  }

  @override
  Future<List<String>> getFavourites() async {
    return _prefs.getStringList('favourites') ?? [];
  }

  @override
  Future<void> setVisibility(Iterable<String> ids, bool value) async {
    String key = 'hidden';
    List<String> currentHidden = await getHidden();
    List<String> newHidden;
    if (!value) {
      newHidden = currentHidden + ids.toList();
    } else {
      newHidden = (currentHidden - ids).toList();
    }
    _prefs.setStringList(key, newHidden.toSet().toList());
  }

  @override
  Future<List<String>> getHidden() async {
    return _prefs.getStringList('hidden') ?? [];
  }

  @override
  Future<void> setTheme(ThemeMode theme) async {
    _prefs.setInt('theme', theme.index);
  }

  @override
  Future<ThemeMode> getTheme() async {
    return ThemeMode.values[_prefs.getInt('theme') ?? 0];
  }

  @override
  Future<void> setViewMode(ViewMode viewMode) async {
    _prefs.setInt('viewMode', viewMode.index);
  }

  @override
  Future<ViewMode> getViewMode() async {
    return ViewMode.values[_prefs.getInt('viewMode') ?? 0];
  }

  @override
  Future<void> setCity(City city) async {
    _prefs.setInt('city', city.index);
  }

  @override
  Future<City> getCity() async {
    return City.values[_prefs.getInt('city') ?? 0];
  }
}

extension IterableExtensions<E> on Iterable<E> {
  Iterable<E> operator -(Iterable<E> other) {
    return toSet().difference(other.toSet());
  }
}

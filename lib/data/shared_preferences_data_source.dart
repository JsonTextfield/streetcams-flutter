import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcams_flutter/data/local_storage_data_source.dart';

class SharedPreferencesDataSource implements ILocalStorageDataSource {
  final SharedPreferences _prefs;

  SharedPreferencesDataSource(this._prefs);

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  void setBool(String key, bool value) {
    _prefs.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  void setInt(String key, int value) {
    _prefs.setInt(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  void setString(String key, String value) {
    _prefs.setString(key, value);
  }
}

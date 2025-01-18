import 'package:streetcams_flutter/data/local_storage_data_source.dart';

class FakeLocalStorageDataSource implements ILocalStorageDataSource {
  final Map<String, Object> map = {};

  @override
  Future<bool?> getBool(String key) async {
    return map[key] as bool?;
  }

  @override
  void setBool(String key, bool value) {
    map[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    return map[key] as int?;
  }

  @override
  void setInt(String key, int value) {
    map[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return map[key] as String?;
  }

  @override
  void setString(String key, String value) {
    map[key] = value;
  }
}

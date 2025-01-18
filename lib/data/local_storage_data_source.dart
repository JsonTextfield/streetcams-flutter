abstract class ILocalStorageDataSource {
  Future<String?> getString(String key);
  void setString(String key, String value);

  Future<int?> getInt(String key);
  void setInt(String key, int value);

  Future<bool?> getBool(String key);
  void setBool(String key, bool value);
}

import 'package:lazycook/config/storage_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// shared_preferences 管理类
class PreferenceUtils {
  static const String _EXPIRED_AT = "_expired_at";

  ///长期保存，如果存在一样的key，则清除过期时间
  static Future saveInteger(String key, int value) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT")) {
      StorageManager.sharedPreferences.remove("$key$_EXPIRED_AT");
    }
    return StorageManager.sharedPreferences.setInt(key, value);
  }

  static Future saveString(String key, String value) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT")) {
      StorageManager.sharedPreferences.remove("$key$_EXPIRED_AT");
    }
    return StorageManager.sharedPreferences.setString(key, value);
  }

  static Future saveBool(String key, bool value) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT")) {
      StorageManager.sharedPreferences.remove("$key$_EXPIRED_AT");
    }
    return StorageManager.sharedPreferences.setBool(key, value);
  }

  static Future saveDouble(String key, double value) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT")) {
      StorageManager.sharedPreferences.remove("$key$_EXPIRED_AT");
    }
    return StorageManager.sharedPreferences.setDouble(key, value);
  }

  static Future saveStringList(String key, List<String> value) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT")) {
      StorageManager.sharedPreferences.remove("$key$_EXPIRED_AT");
    }
    return StorageManager.sharedPreferences.setStringList(key, value);
  }

  ///带过期时间存储,过期时间单位：秒(s)
  static Future saveIntegerExpired(String key, int value, int expired) async {
    StorageManager.sharedPreferences.setInt("$key$_EXPIRED_AT",
        DateTime.now().millisecondsSinceEpoch + expired * 1000);
    return StorageManager.sharedPreferences.setInt(key, value);
  }

  static Future saveStringExpired(String key, String value, int expired) async {
    StorageManager.sharedPreferences.setInt("$key$_EXPIRED_AT",
        DateTime.now().millisecondsSinceEpoch + expired * 1000);
    return StorageManager.sharedPreferences.setString(key, value);
  }

  static Future saveBoolExpired(String key, bool value, int expired) async {
    StorageManager.sharedPreferences.setInt("$key$_EXPIRED_AT",
        DateTime.now().millisecondsSinceEpoch + expired * 1000);
    return StorageManager.sharedPreferences.setBool(key, value);
  }

  static Future saveDoubleExpired(String key, double value, int expired) async {
    StorageManager.sharedPreferences.setInt("$key$_EXPIRED_AT",
        DateTime.now().millisecondsSinceEpoch + expired * 1000);
    return StorageManager.sharedPreferences.setDouble(key, value);
  }

  static Future saveStringListExpired(
      String key, List<String> value, int expired) async {
    StorageManager.sharedPreferences.setInt("$key$_EXPIRED_AT",
        DateTime.now().millisecondsSinceEpoch + expired * 1000);
    return StorageManager.sharedPreferences.setStringList(key, value);
  }

  ///判断是否存在key
  static Future<bool> containsKey(String key) async {
    if (StorageManager.sharedPreferences.containsKey(key)) {
      if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT") &&
          StorageManager.sharedPreferences.getInt("$key$_EXPIRED_AT") <
              DateTime.now().millisecondsSinceEpoch) {
        ///过期，删除数据
        StorageManager.sharedPreferences.remove(key);
        return false;
      } else {
        return true;
      }
    }
    return false;
  }

  ///取值
  static Future<int> getInteger(String key, [int defaultValue = 0]) async {
    var value = StorageManager.sharedPreferences.getInt(key);
    return value ?? defaultValue;
  }

  static Future<String> getString(String key,
      [String defaultValue = '']) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT") &&
        StorageManager.sharedPreferences.getInt("$key$_EXPIRED_AT") <
            DateTime.now().millisecondsSinceEpoch) {
      ///过期，删除数据，返回默认值
      StorageManager.sharedPreferences.remove(key);
      return defaultValue;
    }
    var value = StorageManager.sharedPreferences.getString(key);
    return value ?? defaultValue;
  }

  static Future<bool> getBool(String key, [bool defaultValue = false]) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT") &&
        StorageManager.sharedPreferences.getInt("$key$_EXPIRED_AT") <
            DateTime.now().millisecondsSinceEpoch) {
      ///过期，删除数据，返回默认值
      StorageManager.sharedPreferences.remove(key);
      return defaultValue;
    }
    var value = StorageManager.sharedPreferences.getBool(key);
    return value ?? defaultValue;
  }

  static Future<double> getDouble(String key,
      [double defaultValue = 0.0]) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT") &&
        StorageManager.sharedPreferences.getInt("$key$_EXPIRED_AT") <
            DateTime.now().millisecondsSinceEpoch) {
      ///过期，删除数据，返回默认值
      StorageManager.sharedPreferences.remove(key);
      return defaultValue;
    }
    var value = StorageManager.sharedPreferences.getDouble(key);
    return value ?? defaultValue;
  }

  static Future<List<String>> getStringList(String key,
      [List<String> defaultValue = const <String>[]]) async {
    if (StorageManager.sharedPreferences.containsKey("$key$_EXPIRED_AT") &&
        StorageManager.sharedPreferences.getInt("$key$_EXPIRED_AT") <
            DateTime.now().millisecondsSinceEpoch) {
      ///过期，删除数据，返回默认值
      StorageManager.sharedPreferences.remove(key);
      return defaultValue;
    }
    var value = StorageManager.sharedPreferences.getStringList(key);
    return value ?? defaultValue;
  }

  ///移除key
  static Future<bool> remove(String key) async {
    StorageManager.sharedPreferences.remove(key);
    return true;
  }
}

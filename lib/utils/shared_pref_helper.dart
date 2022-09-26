import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  final SharedPreferences prefs;
  static SharedPrefHelper instance;

  // key names for prefrence data storage
  static const String IS_LOGGED_IN_BOOL = "is_logged_in";
  static const String IS_ACCOUNT_CREATED_BOOL = "is_account_created";
  //static const String FIREBASE_TOKEN = "firebase_token";
  static const String ACCESS_TOKEN_STRING = "access_token";
  static const String USER_DATA = "user_data";
  static const FIREBASE_TOKEN = "firebase_token";

  // static const String CARD_LIST = "card_list";

  SharedPrefHelper._(this.prefs);

  static Future<void> createInstance() async {
    instance = SharedPrefHelper._(await SharedPreferences.getInstance());
  }

  void putBool(String key, bool value) {
    prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    if (prefs.containsKey(key)) {
      return prefs.getBool(key);
    }
    return defaultValue;
  }

  void putDouble(String key, double value) {
    prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    if (prefs.containsKey(key)) {
      return prefs.getDouble(key);
    }
    return defaultValue;
  }

  void putString(String key, String value) {
    prefs.setString(key, value);
  }

  String getString(String key, {String defaultValue = ""}) {
    if (prefs.containsKey(key)) {
      return prefs.getString(key);
    }
    return defaultValue;
  }

  void putInt(String key, int value) {
    prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    if (prefs.containsKey(key)) {
      return prefs.getInt(key);
    }
    return defaultValue;
  }

  void clear() {
    prefs.clear();
  }

  void remove(String key) {
    prefs.remove(key);
  }
}

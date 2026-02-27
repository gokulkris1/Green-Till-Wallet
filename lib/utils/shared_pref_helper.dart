import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  SharedPrefHelper._(this.prefs);

  final SharedPreferences prefs;
  static SharedPrefHelper? _instance;

  // key names for preference data storage
  static const String isLoggedInKey = "is_logged_in";
  static const String isAccountCreatedKey = "is_account_created";
  static const String accessTokenKey = "access_token";
  static const String userDataKey = "user_data";
  static const String firebaseTokenKey = "firebase_token";

  static SharedPrefHelper get instance {
    final helper = _instance;
    if (helper == null) {
      throw StateError(
          "SharedPrefHelper has not been initialised. Call createInstance() first.");
    }
    return helper;
  }

  static Future<void> createInstance() async {
    _instance = SharedPrefHelper._(await SharedPreferences.getInstance());
  }

  Future<void> putBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> putDouble(String key, double value) async {
    await prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> putString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String getString(String key, {String defaultValue = ""}) {
    return prefs.getString(key) ?? defaultValue;
  }

  Future<void> putInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return prefs.getInt(key) ?? defaultValue;
  }

  Future<void> clear() async {
    await prefs.clear();
  }

  Future<void> remove(String key) async {
    await prefs.remove(key);
  }
}

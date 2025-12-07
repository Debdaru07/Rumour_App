import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchService {
  static const _key = "has_launched";

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> setLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

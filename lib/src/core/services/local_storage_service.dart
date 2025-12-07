import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future<void> cacheMessages(
    String roomId,
    List<Map<String, dynamic>> msgs,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cache_$roomId", jsonEncode(msgs));
  }

  Future<List<Map<String, dynamic>>> loadCachedMessages(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("cache_$roomId");
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }
}

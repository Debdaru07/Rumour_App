import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future<void> saveMessages(
    String roomId,
    List<Map<String, dynamic>> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache_$roomId', jsonEncode(messages));
  }

  Future<List<Map<String, dynamic>>> loadMessages(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_$roomId');
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }
}

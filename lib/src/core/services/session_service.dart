import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RoomSession {
  final String? roomId;
  final Map<String, dynamic>? identity;

  RoomSession({this.roomId, this.identity});
}

class SessionService {
  static Future<RoomSession> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    final roomId = prefs.getString('lastRoomId');
    final identityStr = prefs.getString('identity');

    if (roomId == null || identityStr == null) {
      return RoomSession(roomId: null, identity: null);
    }

    final decoded = jsonDecode(identityStr);

    return RoomSession(roomId: roomId, identity: decoded);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('lastRoomId');
    prefs.remove('identity');
  }
}

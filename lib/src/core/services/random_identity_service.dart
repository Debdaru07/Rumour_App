import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RandomIdentityService {
  Future<Map<String, dynamic>> getIdentity(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'identity_$roomId';

    if (prefs.containsKey(key)) {
      return jsonDecode(prefs.getString(key)!);
    }

    final res = await http.get(Uri.parse("https://randomuser.me/api/"));
    final data = jsonDecode(res.body)['results'][0];

    final identity = {
      "id": data['login']['uuid'],
      "name": "${data['name']['first']} ${data['name']['last']}",
      "avatar": data['picture']['thumbnail'],
    };

    prefs.setString(key, jsonEncode(identity));
    return identity;
  }
}

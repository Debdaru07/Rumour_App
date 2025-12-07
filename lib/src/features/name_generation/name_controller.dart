import 'package:flutter/material.dart';
import '../../core/services/random_identity_service.dart';

class NameController with ChangeNotifier {
  final RandomIdentityService _identityService = RandomIdentityService();
  bool loading = false;
  Map<String, dynamic>? identity;

  Future<void> ensureIdentity(String roomId) async {
    loading = true;
    notifyListeners();
    identity = await _identityService.getIdentity(roomId);
    loading = false;
    notifyListeners();
  }
}

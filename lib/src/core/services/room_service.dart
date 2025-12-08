import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;

  Future<void> createRoom(String roomCode) async {
    final doc = _db.collection('rooms').doc(roomCode.trim());

    final snap = await doc.get();

    if (!snap.exists) {
      await doc.set({
        'roomCode': roomCode,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'members': 0,
      });
    }
  }

  Future<bool> roomExists(String roomCode) async {
    final snap = await _db.collection('rooms').doc(roomCode.trim()).get();
    return snap.exists;
  }
}

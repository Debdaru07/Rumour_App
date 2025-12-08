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

  Stream<int> watchMemberCount(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots().map((snap) {
      if (!snap.exists) return 0;
      final data = snap.data();
      if (data == null) return 0;

      final members = data['members'] as List<dynamic>? ?? [];
      return members.length;
    });
  }

  Future<bool> roomExists(String roomCode) async {
    final snap = await _db.collection('rooms').doc(roomCode.trim()).get();
    return snap.exists;
  }

  Future<void> joinRoom(String roomId, Map<String, dynamic> identity) async {
    final ref = _db.collection('rooms').doc(roomId);

    await ref.update({
      "members": FieldValue.arrayUnion([identity]),
      "lastActive": FieldValue.serverTimestamp(),
    });

    await sendSystemMessage(roomId, "${identity['name']} joined the room");
  }

  Future<void> exitRoom(String roomId, Map<String, dynamic> identity) async {
    final ref = _db.collection('rooms').doc(roomId);

    await ref.update({
      "members": FieldValue.arrayRemove([identity]),
      "lastActive": FieldValue.serverTimestamp(),
    });

    await sendSystemMessage(roomId, "${identity['name']} left the room");
  }

  Future<void> sendSystemMessage(String roomId, String text) async {
    await _db.collection('rooms').doc(roomId).collection('messages').add({
      'type': 'system',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

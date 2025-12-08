import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final _db = FirebaseFirestore.instance;

  Future<String> createRoom(String name, String code) async {
    final ref = await _db.collection("rooms").add({
      "name": name,
      "code": code,
      "members": [],
      "createdAt": FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String?> getRoomIdFromCode(String code) async {
    final snap =
        await _db
            .collection("rooms")
            .where("code", isEqualTo: code)
            .limit(1)
            .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  Future<bool> roomExists(String code) async {
    final snap =
        await _db
            .collection("rooms")
            .where("code", isEqualTo: code)
            .limit(1)
            .get();
    return snap.docs.isNotEmpty;
  }

  Stream<int> watchMemberCount(String roomId) {
    return _db.collection("rooms").doc(roomId).snapshots().map((doc) {
      if (!doc.exists) return 0;
      final data = doc.data()!;
      final members = data["members"] as List<dynamic>? ?? [];
      return members.length;
    });
  }

  Future<void> joinRoom(String roomId, Map<String, dynamic> identity) async {
    await _db.collection("rooms").doc(roomId).update({
      "members": FieldValue.arrayUnion([identity]),
      "lastActive": FieldValue.serverTimestamp(),
    });

    await sendSystemMessage(roomId, "${identity['name']} joined the room");
  }

  Future<void> exitRoom(String roomId, Map<String, dynamic> identity) async {
    await _db.collection("rooms").doc(roomId).update({
      "members": FieldValue.arrayRemove([identity]),
      "lastActive": FieldValue.serverTimestamp(),
    });

    await sendSystemMessage(roomId, "${identity['name']} left the room");
  }

  Future<void> sendSystemMessage(String roomId, String text) async {
    await _db.collection("rooms").doc(roomId).collection("messages").add({
      "type": "system",
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}

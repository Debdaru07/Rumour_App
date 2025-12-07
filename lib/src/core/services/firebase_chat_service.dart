import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChatService {
  final _db = FirebaseFirestore.instance;

  Future<String> createRoom(String code) async {
    final doc = _db.collection('rooms').doc();
    await doc.set({
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String?> getRoomIdByCode(String code) async {
    final snapshot =
        await _db
            .collection('rooms')
            .where('code', isEqualTo: code)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  Stream<QuerySnapshot> watchMessages(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String roomId, Map<String, dynamic> msg) async {
    final ref =
        _db.collection('rooms').doc(roomId).collection('messages').doc();
    await ref.set({...msg, 'createdAt': FieldValue.serverTimestamp()});

    await _db.collection('rooms').doc(roomId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> fetchMessagesPage(
    String roomId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) {
    var q = _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    return q.get();
  }
}

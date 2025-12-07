import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChatService {
  final _db = FirebaseFirestore.instance;

  // Create new room
  Future<String> createRoom(String code) async {
    final doc = _db.collection('rooms').doc();
    await doc.set({
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Find room by code
  Future<String?> getRoomIdByCode(String code) async {
    final result =
        await _db
            .collection('rooms')
            .where('code', isEqualTo: code)
            .limit(1)
            .get();

    if (result.docs.isEmpty) return null;
    return result.docs.first.id;
  }

  // Send message
  Future<void> sendMessage(String roomId, Map<String, dynamic> msg) async {
    final msgRef =
        _db.collection('rooms').doc(roomId).collection('messages').doc();

    await msgRef.set({...msg, 'createdAt': FieldValue.serverTimestamp()});

    await _db.collection('rooms').doc(roomId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  // Listener for realtime messages
  Stream<QuerySnapshot> watchMessages(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Paginated fetch
  Future<QuerySnapshot> fetchMore(String roomId, DocumentSnapshot? lastDoc) {
    var query = _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(20);

    if (lastDoc != null) query = query.startAfterDocument(lastDoc);

    return query.get();
  }
}

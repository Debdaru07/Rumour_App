import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/services/local_storage_service.dart';
import '../../models/message_model.dart';

class ChatController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _local = LocalStorageService();

  final List<MessageModel> messages = [];

  StreamSubscription<QuerySnapshot>? _newMsgSub;
  DocumentSnapshot? _lastDocDesc;

  bool loading = false;
  bool hasMore = true;

  static const int pageSize = 15;

  Future<void> startListening(String roomId) async {
    // Load cached messages first
    try {
      final cached = await _local.loadCachedMessages(roomId);
      if (cached.isNotEmpty) {
        messages.clear();
        messages.addAll(cached.map((m) => MessageModel.fromCachedMap(m)));
        notifyListeners();
      }
    } catch (_) {}

    await _loadLatestPage(roomId);
    _subscribeToNewMessages(roomId);
  }

  Future<void> _loadLatestPage(String roomId) async {
    loading = true;
    notifyListeners();

    final q = _firestore
        .collection('rooms/$roomId/messages')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    final snap = await q.get();

    if (snap.docs.isEmpty) {
      messages.clear();
      hasMore = false;
    } else {
      final pageMsgs =
          snap.docs
              .map((d) => MessageModel.fromFirestore(d))
              .toList()
              .reversed
              .toList();

      messages
        ..clear()
        ..addAll(pageMsgs);

      _lastDocDesc = snap.docs.last;
      hasMore = snap.docs.length == pageSize;
    }

    await _cacheMessages(roomId);

    loading = false;
    notifyListeners();
  }

  void _subscribeToNewMessages(String roomId) {
    _newMsgSub?.cancel();

    Timestamp? latestTs;
    if (messages.isNotEmpty && messages.last.createdAt != null) {
      latestTs = Timestamp.fromDate(messages.last.createdAt!);
    }

    Query q = _firestore
        .collection('rooms/$roomId/messages')
        .orderBy('createdAt');

    q = latestTs != null ? q.startAfter([latestTs]) : q.limit(1);

    _newMsgSub = q.snapshots().listen((snap) async {
      if (snap.docChanges.isEmpty) return;

      bool changed = false;

      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final m = MessageModel.fromFirestore(change.doc);
          if (messages.isEmpty || messages.last.id != m.id) {
            messages.add(m);
            changed = true;
          }
        } else if (change.type == DocumentChangeType.modified) {
          final idx = messages.indexWhere((x) => x.id == change.doc.id);
          if (idx >= 0) {
            messages[idx] = MessageModel.fromFirestore(change.doc);
            changed = true;
          }
        } else if (change.type == DocumentChangeType.removed) {
          messages.removeWhere((x) => x.id == change.doc.id);
          changed = true;
        }
      }

      if (changed) {
        await _cacheMessages(roomId);
        notifyListeners();
      }
    }, onError: (_) {});
  }

  Future<void> loadMore(String roomId) async {
    if (!hasMore || loading) return;

    loading = true;
    notifyListeners();

    try {
      Query q = _firestore
          .collection('rooms/$roomId/messages')
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (_lastDocDesc != null) {
        q = q.startAfterDocument(_lastDocDesc!);
      }

      final snap = await q.get();

      if (snap.docs.isEmpty) {
        hasMore = false;
      } else {
        final newMsgs =
            snap.docs
                .map((d) => MessageModel.fromFirestore(d))
                .toList()
                .reversed
                .toList();

        _lastDocDesc = snap.docs.last;

        final existingIds = messages.map((m) => m.id).toSet();
        for (final m in newMsgs) {
          if (!existingIds.contains(m.id)) {
            messages.insert(0, m);
          }
        }

        await _cacheMessages(roomId);
      }
    } catch (_) {}

    loading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String roomId, Map<String, dynamic> msgMap) async {
    await _firestore.collection('rooms/$roomId/messages').add({
      ...msgMap,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _cacheMessages(String roomId) async {
    try {
      final cached =
          messages
              .map(
                (m) => {
                  'id': m.id,
                  'text': m.text,
                  'senderId': m.senderId,
                  'senderName': m.senderName,
                  'senderAvatar': m.senderAvatar,
                  'type': m.type,
                  'createdAt': m.createdAt?.toIso8601String(),
                },
              )
              .toList();

      await _local.cacheMessages(roomId, cached);
    } catch (_) {}
  }

  @override
  void dispose() {
    _newMsgSub?.cancel();
    _newMsgSub = null;
    super.dispose();
  }
}

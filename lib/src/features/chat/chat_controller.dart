// src/features/chat/chat_controller.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/services/local_storage_service.dart';
import '../../models/message_model.dart';

class ChatController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _local = LocalStorageService();

  final List<MessageModel> messages = [];

  // pagination / streaming
  StreamSubscription<QuerySnapshot>?
  _newMsgSub; // listens to new messages (realtime)
  DocumentSnapshot? _lastDocDesc; // for paginated older pages (descending)
  bool loading = false;
  bool hasMore = true;
  static const int pageSize = 15; // as requested

  // ----------------------------
  // Start: load cached, load latest page, then subscribe to new messages
  // ----------------------------
  Future<void> startListening(String roomId) async {
    // 1) Load cached messages (if any) immediately so UI shows something offline
    try {
      final cached = await _local.loadCachedMessages(roomId);
      if (cached.isNotEmpty) {
        messages.clear();
        messages.addAll(cached.map((m) => MessageModel.fromCachedMap(m)));
        // keep UI updated
        notifyListeners();
      }
    } catch (e) {
      // ignore caching errors
    }

    // 2) Load the latest page (descending) — this returns the newest messages
    await _loadLatestPage(roomId);

    // 3) Start listening for *new* messages that arrive after the latest message
    _subscribeToNewMessages(roomId);
  }

  // ----------------------------
  // Loads the latest page (most recent 'pageSize' messages), ordered asc for UI
  // ----------------------------
  Future<void> _loadLatestPage(String roomId) async {
    loading = true;
    notifyListeners();

    // Query for the latest messages (descending), limit pageSize
    final q = _firestore
        .collection('rooms/$roomId/messages')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    final snap = await q.get();
    if (snap.docs.isEmpty) {
      // no messages
      messages.clear();
      hasMore = false;
    } else {
      // snap.docs is descending (newest first). Convert -> MessageModel,
      // then reverse to ascending order for display (oldest at top)
      final docs = snap.docs;
      final pageMsgs =
          docs
              .map((d) => MessageModel.fromFirestore(d))
              .toList()
              .reversed
              .toList();

      // set messages to these latest messages (replacing cached ones)
      messages.clear();
      messages.addAll(pageMsgs);

      // keep lastDocDesc pointing to the last doc in descending order
      // (so for older pages we can startAfterDocument(lastDocDesc))
      _lastDocDesc = snap.docs.last;

      // There might be more if docs length == pageSize
      hasMore = snap.docs.length == pageSize;
    }

    // cache messages locally (so offline app can show them)
    await _cacheMessages(roomId);

    loading = false;
    notifyListeners();
  }

  // ----------------------------
  // Subscribe to new messages arriving after the newest message we have
  // We query createdAt > latestCreatedAt (or no filter if none) and listen realtime
  // ----------------------------
  void _subscribeToNewMessages(String roomId) {
    // cancel previous if any
    _newMsgSub?.cancel();

    // determine the start time (latest existing message)
    Timestamp? latestTs;
    if (messages.isNotEmpty && messages.last.createdAt != null) {
      latestTs = Timestamp.fromDate(messages.last.createdAt!);
    }

    Query q = _firestore
        .collection('rooms/$roomId/messages')
        .orderBy('createdAt', descending: false);

    if (latestTs != null) {
      // only listen to messages newer than latestTs
      q = q.startAfter([latestTs]);
    } else {
      // no messages yet — listen to last few so that we don't receive whole history repeatedly
      q = q.limit(1);
    }

    _newMsgSub = q.snapshots().listen(
      (snap) async {
        if (snap.docChanges.isEmpty) return;

        // process added docs only
        bool changed = false;
        for (final change in snap.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final m = MessageModel.fromFirestore(change.doc);

            // Prevent duplicate if id already present
            if (messages.isEmpty || messages.last.id != m.id) {
              messages.add(m);
              changed = true;
            }
          } else if (change.type == DocumentChangeType.modified) {
            // update in place
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
          // cache and notify
          await _cacheMessages(roomId);
          notifyListeners();
        }
      },
      onError: (err) {
        // optionally log
      },
    );
  }

  // ----------------------------
  // Load older messages (pagination)
  // Call this when scrolling near top. startAfter uses _lastDocDesc (descending)
  // ----------------------------
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
        // snap.docs is descending; convert -> ascending order before inserting at front
        final newMsgs =
            snap.docs
                .map((d) => MessageModel.fromFirestore(d))
                .toList()
                .reversed
                .toList();

        // Update lastDocDesc for next page (descending)
        _lastDocDesc = snap.docs.last;

        // merge: insert older messages at front without duplicates
        final existingIds = messages.map((m) => m.id).toSet();
        for (final m in newMsgs) {
          if (!existingIds.contains(m.id)) {
            messages.insert(0, m);
          }
        }

        // cache
        await _cacheMessages(roomId);
      }
    } catch (e) {
      // ignore or handle
    }

    loading = false;
    notifyListeners();
  }

  // ----------------------------
  // Send message — server timestamp is used by Firestore
  // ----------------------------
  Future<void> sendMessage(String roomId, Map<String, dynamic> msgMap) async {
    // msgMap should NOT contain createdAt; server will set it
    await _firestore.collection('rooms/$roomId/messages').add({
      ...msgMap,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // realtime listener will pick it up and append
  }

  // ----------------------------
  // Helper: cache messages using LocalStorageService
  // ----------------------------
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
    } catch (e) {
      // ignore
    }
  }

  // ----------------------------
  // Disposal/cancel subscriptions
  // ----------------------------
  @override
  void dispose() {
    _newMsgSub?.cancel();
    _newMsgSub = null;
    super.dispose();
  }
}

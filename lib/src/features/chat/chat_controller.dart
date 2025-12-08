import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/services/firebase_chat_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../models/message_model.dart';

class ChatController with ChangeNotifier {
  final FirebaseChatService _chatService = FirebaseChatService();
  final LocalStorageService _local = LocalStorageService();

  final List<MessageModel> messages = [];
  StreamSubscription<QuerySnapshot>? _sub;

  bool loading = false;

  DocumentSnapshot? lastDocDesc; // for pagination
  bool hasMore = true;
  static const int pageSize = 20;

  // ---------------------------------------------------------------------------
  // START LISTENING
  // ---------------------------------------------------------------------------
  void startListening(String roomId) {
    // 1️⃣ Load cached messages first
    _local.loadCachedMessages(roomId).then((cached) {
      if (cached.isNotEmpty) {
        messages.clear();
        messages.addAll(
          cached.map(
            (m) => MessageModel(
              id: m['id'] ?? '',
              text: m['text'] ?? '',
              senderId: m['senderId'] ?? '',
              senderName: m['senderName'] ?? '',
              senderAvatar: m['senderAvatar'] ?? '',
              createdAt:
                  m['createdAt'] != null
                      ? DateTime.tryParse(m['createdAt'])
                      : null,
              type: m['type'] ?? '',
            ),
          ),
        );
        notifyListeners();
      }
    });

    // 2️⃣ Realtime Firestore subscription
    _sub = _chatService.watchMessages(roomId).listen((snapshot) {
      final docs = snapshot.docs;

      messages.clear();
      for (final doc in docs) {
        messages.add(MessageModel.fromFirestore(doc));
      }

      // Cache messages locally for faster load next time
      _local.cacheMessages(
        roomId,
        messages.map((m) {
          return {
            'id': m.id,
            'text': m.text,
            'senderId': m.senderId,
            'senderName': m.senderName,
            'senderAvatar': m.senderAvatar,
            'createdAt': m.createdAt?.toIso8601String(),
            'type': m.type,
          };
        }).toList(),
      );

      notifyListeners();
    });
  }

  // ---------------------------------------------------------------------------
  // CANCEL LISTENER WHEN CONTROLLER IS DISPOSED
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _sub?.cancel(); // 🔥 This is what prevents the crash
    _sub = null;
    super.dispose();
  }

  // (Still keeping this method if you want to call manually somewhere)
  Future<void> disposeListener() async {
    await _sub?.cancel();
    _sub = null;
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------------------------
  Future<void> sendMessage(String roomId, MessageModel msg) async {
    await _chatService.sendMessage(roomId, msg.toMap());
  }

  // ---------------------------------------------------------------------------
  // PAGINATION LOGIC
  // ---------------------------------------------------------------------------
  Future<void> loadMore(String roomId) async {
    if (!hasMore || loading) return;

    loading = true;
    notifyListeners();

    final page = await _chatService.fetchMessagesPage(
      roomId,
      startAfter: lastDocDesc,
      limit: pageSize,
    );

    if (page.docs.isEmpty) {
      hasMore = false;
    } else {
      final newDocs =
          page.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();

      lastDocDesc = page.docs.last;

      final existingIds = messages.map((e) => e.id).toSet();
      for (final msg in newDocs) {
        if (!existingIds.contains(msg.id)) {
          messages.insert(0, msg); // Insert older messages at top
        }
      }

      _local.cacheMessages(
        roomId,
        messages.map((m) {
          return {
            'id': m.id,
            'text': m.text,
            'senderId': m.senderId,
            'senderName': m.senderName,
            'senderAvatar': m.senderAvatar,
            'createdAt': m.createdAt?.toIso8601String(),
            'type': m.type,
          };
        }).toList(),
      );
    }

    loading = false;
    notifyListeners();
  }
}

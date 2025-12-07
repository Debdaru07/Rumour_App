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

  DocumentSnapshot? lastDocDesc; // for pagination (descending query)
  bool hasMore = true;
  static const int pageSize = 20;

  void startListening(String roomId) {
    // First load cached messages
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
            ),
          ),
        );
        notifyListeners();
      }
    });

    // realtime listener
    _sub = _chatService.watchMessages(roomId).listen((snapshot) {
      // rebuild list from snapshot (simple approach)
      final docs = snapshot.docs;
      messages.clear();
      for (final doc in docs) {
        messages.add(MessageModel.fromFirestore(doc));
      }
      // cache to local
      _local.cacheMessages(
        roomId,
        messages
            .map(
              (m) => {
                'id': m.id,
                'text': m.text,
                'senderId': m.senderId,
                'senderName': m.senderName,
                'senderAvatar': m.senderAvatar,
                'createdAt': m.createdAt?.toIso8601String(),
              },
            )
            .toList(),
      );
      notifyListeners();
    });
  }

  Future<void> disposeListener() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> sendMessage(String roomId, MessageModel msg) async {
    await _chatService.sendMessage(roomId, msg.toMap());
  }

  Future<void> loadMore(String roomId) async {
    if (!hasMore) return;
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
      // append older messages to front of current list (since page is descending)
      final newDocs =
          page.docs.map((d) => MessageModel.fromFirestore(d)).toList();
      // update lastDocDesc
      lastDocDesc = page.docs.last;
      // merge without duplicates
      final ids = messages.map((m) => m.id).toSet();
      for (final m in newDocs) {
        if (!ids.contains(m.id)) messages.insert(0, m);
      }
      // cache
      await _local.cacheMessages(
        roomId,
        messages
            .map(
              (m) => {
                'id': m.id,
                'text': m.text,
                'senderId': m.senderId,
                'senderName': m.senderName,
                'senderAvatar': m.senderAvatar,
                'createdAt': m.createdAt?.toIso8601String(),
              },
            )
            .toList(),
      );
    }

    loading = false;
    notifyListeners();
  }
}

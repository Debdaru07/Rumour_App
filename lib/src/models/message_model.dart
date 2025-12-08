import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, Timestamp;

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String type;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.type,
    this.createdAt,
  });

  factory MessageModel.fromJson(String id, Map<String, dynamic> json) {
    return MessageModel(
      id: id,
      text: json['text'] ?? "",
      senderId: json['senderId'] ?? "",
      senderName: json['senderName'] ?? "System",
      senderAvatar: json['senderAvatar'] ?? "",
      type: json['type'] ?? "user",
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : null,
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel(
      id: doc.id,
      text: json['text'] ?? "",
      senderId: json['senderId'] ?? "",
      senderName: json['senderName'] ?? "System",
      senderAvatar: json['senderAvatar'] ?? "",
      type: json['type'] ?? "user",
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory MessageModel.fromCachedMap(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? "",
      text: json['text'] ?? "",
      senderId: json['senderId'] ?? "",
      senderName: json['senderName'] ?? "System",
      senderAvatar: json['senderAvatar'] ?? "",
      type: json['type'] ?? "user",
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'type': type,
  };

  Map<String, dynamic> toCacheMap() => {
    'id': id,
    'text': text,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'type': type,
    'createdAt': createdAt?.toIso8601String(),
  };
}

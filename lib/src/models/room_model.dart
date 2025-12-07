import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String code;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;

  RoomModel({
    required this.id,
    required this.code,
    this.createdAt,
    this.lastMessageAt,
  });

  factory RoomModel.fromJson(String id, Map<String, dynamic> json) {
    return RoomModel(
      id: id,
      code: json['code'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
      lastMessageAt: (json['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }
}

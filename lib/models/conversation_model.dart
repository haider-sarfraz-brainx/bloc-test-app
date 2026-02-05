import 'package:equatable/equatable.dart';

class ConversationModel extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessageAt,
    required this.createdAt,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      user1Id: map['user1_id'] ?? '',
      user2Id: map['user2_id'] ?? '',
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, user1Id, user2Id, lastMessageAt, createdAt];
}

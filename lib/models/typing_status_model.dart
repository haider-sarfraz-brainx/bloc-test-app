import 'package:equatable/equatable.dart';

class TypingStatusModel extends Equatable {
  final String conversationId;
  final String userId;
  final bool isTyping;
  final DateTime updatedAt;

  const TypingStatusModel({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
    required this.updatedAt,
  });

  factory TypingStatusModel.fromMap(Map<String, dynamic> map) {
    return TypingStatusModel(
      conversationId: map['conversation_id'] ?? '',
      userId: map['user_id'] ?? '',
      isTyping: map['is_typing'] ?? false,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversation_id': conversationId,
      'user_id': userId,
      'is_typing': isTyping,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [conversationId, userId, isTyping, updatedAt];
}

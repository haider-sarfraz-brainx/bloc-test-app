import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversation_id'] ?? '',
      senderId: map['sender_id'] ?? '',
      content: map['content'] ?? '',
      messageType: map['message_type'] ?? 'text',
      isRead: map['is_read'] ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? messageType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, conversationId, senderId, content, messageType, isRead, createdAt];
}

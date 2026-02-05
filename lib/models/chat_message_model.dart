import 'package:equatable/equatable.dart';
import 'message_model.dart';

/// UI model for displaying messages in chat room
class ChatMessage extends Equatable {
  final String text;
  final bool isSent;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isSent,
    required this.timestamp,
  });

  factory ChatMessage.fromMessageModel(
    MessageModel message,
    String currentUserId,
  ) {
    return ChatMessage(
      text: message.content,
      isSent: message.senderId == currentUserId,
      timestamp: message.createdAt,
    );
  }

  @override
  List<Object?> get props => [text, isSent, timestamp];
}

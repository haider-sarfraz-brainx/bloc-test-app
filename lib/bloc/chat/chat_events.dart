import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class SendMessage extends ChatEvent {
  final String conversationId;
  final String content;
  final String messageType;

  const SendMessage({
    required this.conversationId,
    required this.content,
    this.messageType = 'text',
  });

  @override
  List<Object?> get props => [conversationId, content, messageType];
}

class MessageReceived extends ChatEvent {
  final Map<String, dynamic> messageData;

  const MessageReceived(this.messageData);

  @override
  List<Object?> get props => [messageData];
}

class MarkMessagesAsRead extends ChatEvent {
  final String conversationId;

  const MarkMessagesAsRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class UpdateTypingStatus extends ChatEvent {
  final String conversationId;
  final bool isTyping;

  const UpdateTypingStatus({
    required this.conversationId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [conversationId, isTyping];
}

class TypingStatusChanged extends ChatEvent {
  final Map<String, dynamic> typingData;

  const TypingStatusChanged(this.typingData);

  @override
  List<Object?> get props => [typingData];
}

class RefreshMessages extends ChatEvent {
  final String conversationId;

  const RefreshMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

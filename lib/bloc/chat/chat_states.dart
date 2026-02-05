import 'package:equatable/equatable.dart';
import '../../models/message_model.dart';
import '../../models/typing_status_model.dart';

class ChatState extends Equatable {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final TypingStatusModel? typingStatus;
  final String? conversationId;

  const ChatState({
    required this.messages,
    required this.isLoading,
    required this.isSending,
    this.error,
    this.typingStatus,
    this.conversationId,
  });

  factory ChatState.initial() {
    return const ChatState(
      messages: [],
      isLoading: false,
      isSending: false,
      error: null,
      typingStatus: null,
      conversationId: null,
    );
  }

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    TypingStatusModel? typingStatus,
    String? conversationId,
    bool clearError = false,
    bool clearTypingStatus = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      typingStatus:
          clearTypingStatus ? null : (typingStatus ?? this.typingStatus),
      conversationId: conversationId ?? this.conversationId,
    );
  }

  @override
  List<Object?> get props =>
      [messages, isLoading, isSending, error, typingStatus, conversationId];
}

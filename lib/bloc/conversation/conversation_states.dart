import 'package:equatable/equatable.dart';
import '../../models/conversation_model.dart';
import '../../models/profile_model.dart';

class ConversationWithUser {
  final ConversationModel conversation;
  final ProfileModel otherUser;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ConversationWithUser({
    required this.conversation,
    required this.otherUser,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class ConversationState extends Equatable {
  final List<ConversationWithUser> conversations;
  final bool isLoading;
  final String? error;

  const ConversationState({
    required this.conversations,
    required this.isLoading,
    this.error,
  });

  factory ConversationState.initial() {
    return const ConversationState(
      conversations: [],
      isLoading: false,
      error: null,
    );
  }

  ConversationState copyWith({
    List<ConversationWithUser>? conversations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [conversations, isLoading, error];
}

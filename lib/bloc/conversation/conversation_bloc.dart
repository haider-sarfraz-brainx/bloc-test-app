import 'package:bloc_test/bloc/conversation/conversation_events.dart';
import 'package:bloc_test/bloc/conversation/conversation_states.dart';
import 'package:bloc_test/models/conversation_model.dart';
import 'package:bloc_test/models/message_model.dart';
import 'package:bloc_test/models/profile_model.dart';
import 'package:bloc_test/schema/authentication/auth_schema.dart';
import 'package:bloc_test/schema/chat/chat_schema.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConversationBloc
    extends Bloc<ConversationEvent, ConversationState> {
  String? _currentUserId;

  ConversationBloc() : super(ConversationState.initial()) {
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    on<LoadConversations>(_onLoadConversations);
    on<RefreshConversations>(_onRefreshConversations);
    on<ConversationUpdated>(_onConversationUpdated);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    if (_currentUserId == null) {
      emit(state.copyWith(
        error: 'User not authenticated',
        isLoading: false,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final conversations = await ChatSchema.getUserConversations(_currentUserId!);

      final conversationsWithUsers = await Future.wait(
        conversations.map((conv) => _enrichConversation(conv)),
      );

      emit(state.copyWith(
        conversations: conversationsWithUsers,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      print('❌ Error in ConversationBloc._onLoadConversations: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<ConversationState> emit,
  ) async {
    add(const LoadConversations());
  }

  void _onConversationUpdated(
    ConversationUpdated event,
    Emitter<ConversationState> emit,
  ) {
    // Handle real-time conversation updates
    add(const RefreshConversations());
  }

  Future<ConversationWithUser> _enrichConversation(
    ConversationModel conversation,
  ) async {
    // Get the other user's ID
    final otherUserId = conversation.user1Id == _currentUserId
        ? conversation.user2Id
        : conversation.user1Id;

    // Get the other user's profile
    ProfileModel? otherUser;
    try {
      otherUser = await AuthSchema.getUserProfile(otherUserId);
    } catch (e) {
      print('❌ Error fetching user profile: $e');
      otherUser = ProfileModel(
        id: otherUserId,
        name: 'Unknown User',
        email: '',
      );
    }

    // Get the last message
    final messages = await ChatSchema.getConversationMessages(
      conversation.id,
      limit: 1,
    );

    String? lastMessage;
    DateTime? lastMessageTime;
    if (messages.isNotEmpty) {
      lastMessage = messages.last.content;
      lastMessageTime = messages.last.createdAt;
    }

    // Get unread count (simplified - you might want to improve this)
    int unreadCount = 0;
    if (messages.isNotEmpty) {
      unreadCount = messages
          .where((m) => m.senderId != _currentUserId && !m.isRead)
          .length;
    }

    return ConversationWithUser(
      conversation: conversation,
      otherUser: otherUser!,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime ?? conversation.lastMessageAt,
      unreadCount: unreadCount,
    );
  }
}

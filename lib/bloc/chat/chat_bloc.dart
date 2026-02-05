import 'package:bloc_test/bloc/chat/chat_events.dart';
import 'package:bloc_test/bloc/chat/chat_states.dart';
import 'package:bloc_test/models/message_model.dart';
import 'package:bloc_test/models/typing_status_model.dart';
import 'package:bloc_test/schema/chat/chat_schema.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _typingChannel;
  String? _currentUserId;

  ChatBloc() : super(ChatState.initial()) {
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MessageReceived>(_onMessageReceived);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<UpdateTypingStatus>(_onUpdateTypingStatus);
    on<TypingStatusChanged>(_onTypingStatusChanged);
    on<RefreshMessages>(_onRefreshMessages);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      conversationId: event.conversationId,
    ));

    try {
      final messages = await ChatSchema.getConversationMessages(
        event.conversationId,
      );

      // Subscribe to real-time updates
      _subscribeToMessages(event.conversationId);
      _subscribeToTypingStatus(event.conversationId);

      // Mark messages as read
      if (_currentUserId != null) {
        await ChatSchema.markMessagesAsRead(
          conversationId: event.conversationId,
          userId: _currentUserId!,
        );
      }

      emit(state.copyWith(
        messages: messages,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      print('❌ Error in ChatBloc._onLoadMessages: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (event.content.trim().isEmpty) return;

    emit(state.copyWith(isSending: true, error: null));

    try {
      final message = await ChatSchema.sendMessage(
        conversationId: event.conversationId,
        senderId: _currentUserId ?? '',
        content: event.content.trim(),
        messageType: event.messageType,
      );

      if (message != null) {
        final updatedMessages = List<MessageModel>.from(state.messages)
          ..add(message);

        emit(state.copyWith(
          messages: updatedMessages,
          isSending: false,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          isSending: false,
          error: 'Failed to send message',
        ));
      }
    } catch (e) {
      print('❌ Error in ChatBloc._onSendMessage: $e');
      emit(state.copyWith(
        isSending: false,
        error: e.toString(),
      ));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<ChatState> emit,
  ) {
    try {
      final message = MessageModel.fromMap(event.messageData);

      // Check if message already exists
      final exists = state.messages.any((m) => m.id == message.id);
      if (exists) return;

      final updatedMessages = List<MessageModel>.from(state.messages)
        ..add(message);

      emit(state.copyWith(messages: updatedMessages));

      // Mark as read if it's not from current user
      if (_currentUserId != null && message.senderId != _currentUserId) {
        ChatSchema.markMessagesAsRead(
          conversationId: message.conversationId,
          userId: _currentUserId!,
        );
      }
    } catch (e) {
      print('❌ Error in ChatBloc._onMessageReceived: $e');
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentUserId == null) return;

    try {
      await ChatSchema.markMessagesAsRead(
        conversationId: event.conversationId,
        userId: _currentUserId!,
      );

      // Update local state
      final updatedMessages = state.messages.map((message) {
        if (message.senderId != _currentUserId && !message.isRead) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      print('❌ Error in ChatBloc._onMarkMessagesAsRead: $e');
    }
  }

  Future<void> _onUpdateTypingStatus(
    UpdateTypingStatus event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentUserId == null) return;

    try {
      await ChatSchema.updateTypingStatus(
        conversationId: event.conversationId,
        userId: _currentUserId!,
        isTyping: event.isTyping,
      );
    } catch (e) {
      print('❌ Error in ChatBloc._onUpdateTypingStatus: $e');
    }
  }

  void _onTypingStatusChanged(
    TypingStatusChanged event,
    Emitter<ChatState> emit,
  ) {
    try {
      final typingStatus = TypingStatusModel.fromMap(event.typingData);

      // Only show typing status if it's from the other user
      if (typingStatus.userId != _currentUserId) {
        emit(state.copyWith(typingStatus: typingStatus));
      } else {
        emit(state.copyWith(clearTypingStatus: true));
      }
    } catch (e) {
      print('❌ Error in ChatBloc._onTypingStatusChanged: $e');
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<ChatState> emit,
  ) async {
    add(LoadMessages(event.conversationId));
  }

  void _subscribeToMessages(String conversationId) {
    _messagesChannel?.unsubscribe();
    _messagesChannel = ChatSchema.subscribeToMessages(
      conversationId,
      (messageData) {
        add(MessageReceived(messageData));
      },
    );
  }

  void _subscribeToTypingStatus(String conversationId) {
    _typingChannel?.unsubscribe();
    _typingChannel = ChatSchema.subscribeToTypingStatus(
      conversationId,
      (typingData) {
        add(TypingStatusChanged(typingData));
      },
    );
  }

  @override
  Future<void> close() {
    _messagesChannel?.unsubscribe();
    _typingChannel?.unsubscribe();
    return super.close();
  }
}

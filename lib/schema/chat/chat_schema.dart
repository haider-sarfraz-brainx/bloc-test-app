import 'package:bloc_test/models/conversation_model.dart';
import 'package:bloc_test/models/message_model.dart';
import 'package:bloc_test/models/typing_status_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatSchema {
  /// Get or create a conversation between two users
  static Future<ConversationModel?> getOrCreateConversation({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      // Check if conversation already exists (in either direction)
      // Try first combination: user1_id = user1Id AND user2_id = user2Id
      var existingConversation = await Supabase.instance.client
          .from('conversations')
          .select()
          .eq('user1_id', user1Id)
          .eq('user2_id', user2Id)
          .maybeSingle();

      if (existingConversation != null) {
        return ConversationModel.fromMap(existingConversation);
      }

      // Try second combination: user1_id = user2Id AND user2_id = user1Id
      existingConversation = await Supabase.instance.client
          .from('conversations')
          .select()
          .eq('user1_id', user2Id)
          .eq('user2_id', user1Id)
          .maybeSingle();

      if (existingConversation != null) {
        return ConversationModel.fromMap(existingConversation);
      }

      // Create new conversation
      final response = await Supabase.instance.client
          .from('conversations')
          .insert({
            'user1_id': user1Id,
            'user2_id': user2Id,
          })
          .select()
          .single();

      return ConversationModel.fromMap(response);
    } catch (e) {
      print('❌ Error in ChatSchema.getOrCreateConversation: $e');
      return null;
    }
  }

  /// Get conversation by ID
  static Future<ConversationModel?> getConversationById(
    String conversationId,
  ) async {
    try {
      final response = await Supabase.instance.client
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .single();

      return ConversationModel.fromMap(response);
    } catch (e) {
      print('❌ Error in ChatSchema.getConversationById: $e');
      return null;
    }
  }

  /// Get all conversations for a user
  static Future<List<ConversationModel>> getUserConversations(
    String userId,
  ) async {
    try {
      // Get conversations where user is user1
      final user1Conversations = await Supabase.instance.client
          .from('conversations')
          .select()
          .eq('user1_id', userId);

      // Get conversations where user is user2
      final user2Conversations = await Supabase.instance.client
          .from('conversations')
          .select()
          .eq('user2_id', userId);

      // Combine and deduplicate
      final allConversations = <Map<String, dynamic>>[];
      
      if (user1Conversations.isNotEmpty) {
        allConversations.addAll(
          (user1Conversations as List).cast<Map<String, dynamic>>(),
        );
      }
      
      if (user2Conversations.isNotEmpty) {
        allConversations.addAll(
          (user2Conversations as List).cast<Map<String, dynamic>>(),
        );
      }

      if (allConversations.isEmpty) {
        return [];
      }

      // Convert to models and sort by last_message_at
      final conversations = allConversations
          .map((item) => ConversationModel.fromMap(item))
          .toList();

      conversations.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime); // Descending order
      });

      return conversations;
    } catch (e) {
      print('❌ Error in ChatSchema.getUserConversations: $e');
      return [];
    }
  }

  /// Send a message
  static Future<MessageModel?> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': content,
            'message_type': messageType,
          })
          .select()
          .single();

      // Update conversation's last_message_at
      await Supabase.instance.client
          .from('conversations')
          .update({
            'last_message_at': DateTime.now().toIso8601String(),
          })
          .eq('id', conversationId);

      return MessageModel.fromMap(response);
    } catch (e) {
      print('❌ Error in ChatSchema.sendMessage: $e');
      return null;
    }
  }

  /// Get messages for a conversation
  static Future<List<MessageModel>> getConversationMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (response.isEmpty) {
        return [];
      }

      final messages = (response as List)
          .map((item) => MessageModel.fromMap(item))
          .toList();

      // Reverse to show oldest first
      return messages.reversed.toList();
    } catch (e) {
      print('❌ Error in ChatSchema.getConversationMessages: $e');
      return [];
    }
  }

  /// Mark messages as read
  static Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      // Update messages as read
      await Supabase.instance.client
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);

      // Insert into message_reads table
      final unreadMessages = await Supabase.instance.client
          .from('messages')
          .select('id')
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      if (unreadMessages.isNotEmpty) {
        final readRecords = (unreadMessages as List).map((msg) => {
              'message_id': msg['id'],
              'user_id': userId,
            }).toList();

        await Supabase.instance.client
            .from('message_reads')
            .insert(readRecords);
      }
    } catch (e) {
      print('❌ Error in ChatSchema.markMessagesAsRead: $e');
    }
  }

  /// Update typing status
  static Future<void> updateTypingStatus({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await Supabase.instance.client.from('typing_status').upsert({
        'conversation_id': conversationId,
        'user_id': userId,
        'is_typing': isTyping,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error in ChatSchema.updateTypingStatus: $e');
    }
  }

  /// Get typing status for a conversation
  static Future<TypingStatusModel?> getTypingStatus({
    required String conversationId,
    required String userId,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('typing_status')
          .select()
          .eq('conversation_id', conversationId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return TypingStatusModel.fromMap(response);
    } catch (e) {
      print('❌ Error in ChatSchema.getTypingStatus: $e');
      return null;
    }
  }

  /// Subscribe to new messages in a conversation
  static RealtimeChannel subscribeToMessages(
    String conversationId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    final channel = Supabase.instance.client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            onMessage(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }

  /// Subscribe to typing status changes
  static RealtimeChannel subscribeToTypingStatus(
    String conversationId,
    Function(Map<String, dynamic>) onTypingChange,
  ) {
    final channel = Supabase.instance.client
        .channel('typing:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'typing_status',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            onTypingChange(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }
}

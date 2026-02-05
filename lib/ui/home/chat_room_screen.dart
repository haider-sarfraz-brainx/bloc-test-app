import 'package:bloc_test/bloc/chat/chat_bloc.dart';
import 'package:bloc_test/bloc/chat/chat_events.dart';
import 'package:bloc_test/models/chat_message_model.dart';
import 'package:bloc_test/models/profile_model.dart';
import 'package:bloc_test/schema/chat/chat_schema.dart';
import 'package:bloc_test/services/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../bloc/chat/chat_states.dart';
import '../../mixin/app_mixins.dart';

class ChatRoomScreen extends StatefulWidget {
  final ProfileModel user;

  const ChatRoomScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> with TimeMixin, ChatMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? _conversationId;
  String? _currentUserId;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                getInitials(widget.user.name),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final typingStatus = state.typingStatus;
                      if (typingStatus != null &&
                          typingStatus.isTyping &&
                          typingStatus.userId != _currentUserId) {
                        return Text(
                          'typing...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }
                      return Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[700]),
            onPressed: () {
              // TODO: Show more options menu
            },
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
            if (state.isLoading && state.messages.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null && state.messages.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading messages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error ?? 'Unknown error',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_conversationId != null) {
                            context.read<ChatBloc>().add(
                                  RefreshMessages(_conversationId!),
                                );
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final chatMessages = state.messages
                .map((msg) => ChatMessage.fromMessageModel(msg, _currentUserId ?? ''))
                .toList();

            return Column(
              children: [
                Expanded(
                  child: chatMessages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = chatMessages[index];
                            final showTime = index == 0 ||
                                chatMessages[index - 1].timestamp
                                        .difference(message.timestamp)
                                        .inMinutes >
                                    5;

                            return Column(
                              crossAxisAlignment: message.isSent
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (showTime)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          formatTime(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                _buildMessageBubble(message),
                              ],
                            );
                          },
                        ),
                ),
                _buildMessageInput(state.isSending),
              ],
            );
          },
        ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              getInitials(widget.user.name),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start the conversation',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isSent) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                getInitials(widget.user.name),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: message.isSent
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isSent ? 18 : 4),
                  bottomRight: Radius.circular(message.isSent ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: message.isSent ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isSent) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[200],
              child: Text(
                'Me',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isSending) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    onChanged: _onTextChanged,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !isSending,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                  onPressed: isSending ? null : _sendMessage,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initializeConversation() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    _currentUserId = currentUser.id;
    final conversation = await ChatSchema.getOrCreateConversation(
      user1Id: currentUser.id,
      user2Id: widget.user.id ?? '',
    );

    if (conversation != null && mounted) {
      setState(() {
        _conversationId = conversation.id;
      });

      // Load messages
      context.read<ChatBloc>().add(LoadMessages(conversation.id));
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _conversationId == null) {
      return;
    }

    context.read<ChatBloc>().add(
      SendMessage(
        conversationId: _conversationId!,
        content: _messageController.text.trim(),
      ),
    );

    _messageController.clear();
    _updateTypingStatus(false);
    _scrollToBottom();
  }

  void _onTextChanged(String text) {
    if (_conversationId == null) return;

    final isTyping = text.trim().isNotEmpty;
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      _updateTypingStatus(isTyping);
    }
  }

  void _updateTypingStatus(bool isTyping) {
    if (_conversationId == null) return;
    context.read<ChatBloc>().add(
      UpdateTypingStatus(
        conversationId: _conversationId!,
        isTyping: isTyping,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _updateTypingStatus(false);
    super.dispose();
  }


}

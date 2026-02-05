import 'package:bloc_test/bloc/conversation/conversation_bloc.dart';
import 'package:bloc_test/bloc/conversation/conversation_events.dart';
import 'package:bloc_test/models/profile_model.dart';
import 'package:bloc_test/schema/chat/chat_schema.dart';
import 'package:bloc_test/ui/home/chat_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../bloc/conversation/conversation_states.dart';
import '../../mixin/app_mixins.dart';
import '../../widget/custom_search_bar.dart';
import 'users_list_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>  with TimeMixin, ChatMixin {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(const LoadConversations());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            CustomSearchBar(
              onSearch: (text) {
                setState(() {
                  _searchQuery = text.toLowerCase();
                });
              },
            ),
            Expanded(
              child: BlocBuilder<ConversationBloc, ConversationState>(
                builder: (context, state) {
                  if (state.isLoading && state.conversations.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.error != null && state.conversations.isEmpty) {
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
                              'Error loading conversations',
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
                                context
                                    .read<ConversationBloc>()
                                    .add(const RefreshConversations());
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filteredConversations = _searchQuery.isEmpty
                      ? state.conversations
                      : state.conversations.where((conv) {
                          return conv.otherUser.name
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              conv.otherUser.email
                                  .toLowerCase()
                                  .contains(_searchQuery);
                        }).toList();

                  return filteredConversations.isEmpty
                      ? _buildEmptyState(state.conversations.isEmpty)
                      : RefreshIndicator(
                          onRefresh: () async {
                            context
                                .read<ConversationBloc>()
                                .add(const RefreshConversations());
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filteredConversations.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              indent: 80,
                            ),
                            itemBuilder: (context, index) {
                              final conversation = filteredConversations[index];
                              return _buildChatItem(conversation);
                            },
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UsersListScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(bool noConversations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noConversations ? Icons.chat_bubble_outline : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            noConversations
                ? 'No conversations yet'
                : 'No conversations match your search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noConversations
                ? 'Start a new conversation'
                : 'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ConversationWithUser conversation) {
    return InkWell(
      onTap: () => _navigateToChatRoom(conversation.otherUser),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _profileBubbleWidget(conversation),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUser.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageTime != null)
                        Text(
                          formatTime(conversation.lastMessageTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: conversation.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileBubbleWidget(ConversationWithUser conversation){
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Text(
            getInitials(conversation.otherUser.name),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToChatRoom(ProfileModel user) async {
    // Get or create conversation
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final conversation = await ChatSchema.getOrCreateConversation(
      user1Id: currentUser.id,
      user2Id: user.id ?? '',
    );

    if (conversation != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(user: user),
        ),
      );
    }
  }
}

import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationEvent {
  const LoadConversations();
}

class RefreshConversations extends ConversationEvent {
  const RefreshConversations();
}

class ConversationUpdated extends ConversationEvent {
  final Map<String, dynamic> conversationData;

  const ConversationUpdated(this.conversationData);

  @override
  List<Object?> get props => [conversationData];
}

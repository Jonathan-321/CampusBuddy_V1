import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class CampusAIEvent extends Equatable {
  const CampusAIEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load conversation history
class LoadConversationHistory extends CampusAIEvent {}

/// Event to send a new message to Campus Oracle
class SendMessage extends CampusAIEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// Event to clear conversation history
class ClearConversation extends CampusAIEvent {}

/// Internal event when a message is received from the assistant
class MessageReceived extends CampusAIEvent {
  final ChatMessage message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

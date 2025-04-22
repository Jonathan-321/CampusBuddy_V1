import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class CampusAIState extends Equatable {
  const CampusAIState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the chat is first opened
class CampusAIInitial extends CampusAIState {}

/// State when conversation history is being loaded
class CampusAILoading extends CampusAIState {}

/// State when message is being sent to the assistant
class CampusAISending extends CampusAIState {
  final List<ChatMessage> messages;

  const CampusAISending(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// State when conversation is loaded and ready
class CampusAILoaded extends CampusAIState {
  final List<ChatMessage> messages;

  const CampusAILoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// State when an error occurs in the chat
class CampusAIError extends CampusAIState {
  final String message;
  final List<ChatMessage> messages;

  const CampusAIError(this.message, this.messages);

  @override
  List<Object?> get props => [message, messages];
}

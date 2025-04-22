import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'campus_ai_event.dart';
import 'campus_ai_state.dart';
import '../../../domain/usecases/campus_ai_usecases.dart';
import '../../../domain/entities/chat_message.dart';

class CampusAIBloc extends Bloc<CampusAIEvent, CampusAIState> {
  final GetConversationHistoryUseCase getConversationHistory;
  final SendMessageUseCase sendMessage;
  final ClearConversationUseCase clearConversation;

  List<ChatMessage> _messages = [];

  CampusAIBloc({
    required this.getConversationHistory,
    required this.sendMessage,
    required this.clearConversation,
  }) : super(CampusAIInitial()) {
    on<LoadConversationHistory>(_onLoadConversationHistory);
    on<SendMessage>(_onSendMessage);
    on<ClearConversation>(_onClearConversation);
    on<MessageReceived>(_onMessageReceived);
  }

  Future<void> _onLoadConversationHistory(
    LoadConversationHistory event,
    Emitter<CampusAIState> emit,
  ) async {
    emit(CampusAILoading());

    try {
      _messages = await getConversationHistory();

      // Add initial message if chat is empty
      if (_messages.isEmpty) {
        final initialMessage = ChatMessage(
          id: DateTime.now().toString(),
          content:
              'Hello! I\'m Campus Oracle, your campus assistant. How can I help you today?',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        );
        _messages = [initialMessage];
      }

      emit(CampusAILoaded(_messages));
    } catch (e) {
      debugPrint('Error loading conversation history: $e');
      emit(CampusAIError('Failed to load conversation history', _messages));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<CampusAIState> emit,
  ) async {
    // Show user message and loading state immediately
    final userMessage = ChatMessage(
      id: DateTime.now().toString(),
      content: event.message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    // Add user message to chat
    _messages = [..._messages, userMessage];
    emit(CampusAISending(_messages));

    try {
      // Send message to AI
      final response = await sendMessage(event.message, _messages);

      // Update messages with AI response
      _messages = [..._messages.where((msg) => !msg.isLoading), response];

      emit(CampusAILoaded(_messages));
    } catch (e) {
      debugPrint('Error sending message: $e');
      emit(CampusAIError('Failed to send message', _messages));
    }
  }

  Future<void> _onClearConversation(
    ClearConversation event,
    Emitter<CampusAIState> emit,
  ) async {
    emit(CampusAILoading());

    try {
      await clearConversation();

      // Add welcome message
      final initialMessage = ChatMessage(
        id: DateTime.now().toString(),
        content:
            'Hello! I\'m Campus Oracle, your campus assistant. How can I help you today?',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      _messages = [initialMessage];
      emit(CampusAILoaded(_messages));
    } catch (e) {
      debugPrint('Error clearing conversation: $e');
      emit(CampusAIError('Failed to clear conversation', _messages));
    }
  }

  Future<void> _onMessageReceived(
    MessageReceived event,
    Emitter<CampusAIState> emit,
  ) async {
    _messages = [..._messages, event.message];
    emit(CampusAILoaded(_messages));
  }
}

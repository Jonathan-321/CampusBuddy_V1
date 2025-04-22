import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/campus_ai_repository.dart';
import '../../domain/core/failures.dart';
import '../models/chat_message_model.dart';
import '../services/claude_api_service.dart';

class CampusAIRepositoryImpl implements CampusAIRepository {
  final ClaudeApiService _apiService;
  final SharedPreferences _preferences;
  static const String _chatHistoryKey = 'campus_oracle_chat_history';
  final _uuid = const Uuid();

  CampusAIRepositoryImpl(this._apiService, this._preferences);

  @override
  Future<List<ChatMessage>> getConversationHistory() async {
    try {
      final jsonString = _preferences.getString(_chatHistoryKey);
      if (jsonString == null) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final messages = jsonList
          .map((json) => ChatMessageModel.fromJson(json).toEntity())
          .toList();

      return messages;
    } catch (e) {
      debugPrint('Error retrieving chat history: $e');
      return [];
    }
  }

  @override
  Future<void> clearConversation() async {
    try {
      await _preferences.remove(_chatHistoryKey);
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
      throw const CacheFailure('Failed to clear conversation history');
    }
  }

  @override
  Future<ChatMessage> sendMessage(
      String message, List<ChatMessage> context) async {
    try {
      // Create and save user message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: message,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      // Create placeholder for assistant response while waiting
      final placeholderResponse = ChatMessage(
        id: _uuid.v4(),
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        isLoading: true,
      );

      // Save both messages to history
      final updatedHistory =
          await _addMessagesToHistory([userMessage, placeholderResponse]);

      // Format message history for Claude API
      List<Map<String, String>> formattedMessages = context.map((msg) {
        return {
          'role': msg.role.toString().split('.').last,
          'content': msg.content,
        };
      }).toList();

      // Add the new user message
      formattedMessages.add({
        'role': 'user',
        'content': message,
      });

      // Send to Claude API
      final response = await _apiService.sendMessage(
        userMessage: message,
        messageHistory: formattedMessages,
      );

      // Extract the assistant's response
      String responseContent;

      // Handle the response format which may differ between web and other platforms
      if (response['content'] != null && response['content'] is List) {
        responseContent = response['content'][0]['text'];
      } else if (kIsWeb) {
        // For web platform with CORS issues, we might get a special format
        responseContent =
            "I can't connect to the Claude API from a web browser due to CORS restrictions. "
            "For a better experience, try using the mobile or desktop app. "
            "Or ask your developer to implement a backend proxy service.";
      } else {
        responseContent =
            "Sorry, I couldn't process your request. Please try again later.";
      }

      final assistantResponse = ChatMessage(
        id: placeholderResponse.id, // Use same ID as placeholder
        content: responseContent,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      // Update the placeholder with the actual response
      await _updateAssistantMessage(placeholderResponse.id, assistantResponse);

      return assistantResponse;
    } catch (e) {
      debugPrint('Error sending message to API: $e');
      // Create error response
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Sorry, I encountered a problem. Please try again later.',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      // Add error message to history
      await _addMessagesToHistory([errorMessage]);

      return errorMessage;
    }
  }

  // Helper method to add messages to history
  Future<List<ChatMessage>> _addMessagesToHistory(
      List<ChatMessage> messages) async {
    try {
      final currentHistory = await getConversationHistory();
      final updatedHistory = [...currentHistory, ...messages];

      // Convert to JSON and save
      final jsonList = updatedHistory
          .map((msg) => ChatMessageModel.fromEntity(msg).toJson())
          .toList();

      await _preferences.setString(_chatHistoryKey, jsonEncode(jsonList));

      return updatedHistory;
    } catch (e) {
      debugPrint('Error adding messages to history: $e');
      throw const CacheFailure('Failed to update conversation history');
    }
  }

  // Helper method to update an assistant message with the actual response
  Future<void> _updateAssistantMessage(
      String messageId, ChatMessage updatedMessage) async {
    try {
      final currentHistory = await getConversationHistory();
      final updatedHistory = currentHistory.map((msg) {
        if (msg.id == messageId) {
          return updatedMessage;
        }
        return msg;
      }).toList();

      // Convert to JSON and save
      final jsonList = updatedHistory
          .map((msg) => ChatMessageModel.fromEntity(msg).toJson())
          .toList();

      await _preferences.setString(_chatHistoryKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error updating assistant message: $e');
      throw const CacheFailure('Failed to update assistant message');
    }
  }
}

import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final String content;
  final String role;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
  });

  // Convert from JSON to ChatMessageModel
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  // Convert to JSON from ChatMessageModel
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
    };
  }

  // Convert from Entity to Model
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      content: entity.content,
      role: entity.role.toString().split('.').last,
      timestamp: entity.timestamp,
      isLoading: entity.isLoading,
    );
  }

  // Convert from Model to Entity
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      content: content,
      role: _parseRole(role),
      timestamp: timestamp,
      isLoading: isLoading,
    );
  }

  // Helper method to convert string role to MessageRole enum
  MessageRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }
}

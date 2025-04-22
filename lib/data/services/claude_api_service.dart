import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service to interact with Claude API
class ClaudeApiService {
  // Direct API URL
  final String baseUrl = 'https://api.anthropic.com/v1/messages';

  // CORS proxy URL for web platform - this is a public CORS proxy for development
  // In production, you should use your own backend proxy
  final String corsProxyUrl =
      'https://cors-anywhere.herokuapp.com/https://api.anthropic.com/v1/messages';

  final String apiKey;
  final String model;

  ClaudeApiService({
    required this.apiKey,
    this.model = 'claude-3-haiku-20240307',
  });

  /// Send a message to Claude API with conversation history for context
  Future<Map<String, dynamic>> sendMessage({
    required String userMessage,
    required List<Map<String, String>> messageHistory,
    double temperature = 0.7,
    int maxTokens = 1024,
    String systemPrompt = 'You are Campus Oracle, a helpful AI assistant for university students. '
        'You specialize in providing information about school events, class schedules, '
        'and the campus directory including places and contact numbers. '
        'Be informative about campus locations, upcoming events, course schedules, and who to contact for various services. '
        'Create realistic examples when needed about classes, courses, events, and campus locations. '
        'Be concise, friendly, and helpful. Focus on helping students easily navigate and use campus resources. '
        'Do not engage with topics unrelated to campus life or academic questions.',
  }) async {
    try {
      // For web platform, we need to handle CORS issues
      // In a real-world scenario, you should have a backend proxy
      final effectiveUrl = kIsWeb ? corsProxyUrl : baseUrl;

      // Headers for the request
      final headers = {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      };

      // For web platform using the CORS proxy, we need to add additional headers
      if (kIsWeb) {
        headers['Origin'] = 'https://campus-buddy.example.com';
        headers['X-Requested-With'] = 'XMLHttpRequest';
      }

      // Make the API request
      final response = await http.post(
        Uri.parse(effectiveUrl),
        headers: headers,
        body: jsonEncode({
          'model': model,
          'messages': messageHistory,
          'system': systemPrompt,
          'max_tokens': maxTokens,
          'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('API Error [${response.statusCode}]: ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in sendMessage: $e');

      // For web platform, provide more helpful error message about CORS
      if (kIsWeb) {
        // When testing on web, show a more informative error message
        return {
          'content': [
            {
              'type': 'text',
              'text': 'Due to CORS restrictions in web browsers, direct API calls to Anthropic\'s API are not possible. '
                  'For a production application, you would need to implement a backend proxy service. '
                  'For testing purposes, you can use a mobile or desktop platform instead.'
            }
          ]
        };
      }

      rethrow;
    }
  }
}

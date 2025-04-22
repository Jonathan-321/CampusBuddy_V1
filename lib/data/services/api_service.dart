import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final http.Client _httpClient;
  final String _baseUrl;
  final String apiKey;

  ApiService({
    http.Client? httpClient,
    String? baseUrl,
    required this.apiKey,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? 'https://api.campusbuddy.example.com/api/v1';

  // Factory constructor for creating a mock implementation
  factory ApiService.mock() {
    return ApiService(baseUrl: 'https://mock-api.com', apiKey: 'mock-key');
  }

  // Generic GET request with caching
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
    bool useCache = true,
    Duration cacheDuration = const Duration(hours: 1),
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$path');
      final cacheKey = 'api_cache_${url.toString()}';

      // Check cache if enabled
      if (useCache) {
        final cachedData = await _getCachedData(cacheKey);
        if (cachedData != null) {
          return cachedData;
        }
      }

      final response = await _httpClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);

        // Cache the result if enabled
        if (useCache) {
          await _cacheData(cacheKey, data, cacheDuration);
        }

        return data;
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to fetch data: $e');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$path');
      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to submit data: $e');
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$path');
      final response = await _httpClient.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to update data: $e');
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$path');
      final response = await _httpClient.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw _handleApiError(response);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to delete data: $e');
    }
  }

  // Cache helpers
  Future<Map<String, dynamic>?> _getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cacheJson = prefs.getString(key);
      if (cacheJson == null) return null;

      final Map<String, dynamic> cacheData = json.decode(cacheJson);
      final DateTime expiryTime = DateTime.parse(cacheData['expiryTime']);

      if (DateTime.now().isBefore(expiryTime)) {
        return cacheData['data'];
      } else {
        // Clear expired cache
        await prefs.remove(key);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheData(
    String key,
    Map<String, dynamic> data,
    Duration duration,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'expiryTime': DateTime.now().add(duration).toIso8601String(),
      };
      await prefs.setString(key, json.encode(cacheData));
    } catch (e) {
      // Silently fail if caching doesn't work
      print('Caching error: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('api_cache_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Error handling
  Exception _handleApiError(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      final String errorMessage =
          errorData['message'] ?? 'Unknown error occurred';
      return Exception('API Error (${response.statusCode}): $errorMessage');
    } catch (e) {
      return Exception(
          'API Error (${response.statusCode}): ${response.reasonPhrase}');
    }
  }
}

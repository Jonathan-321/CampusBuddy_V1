import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/api_service.dart';
import '../models/event_model.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository_interface.dart';

// Simple mock implementation of SharedPreferences for testing
class _MockSharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  Future<bool> commit() async => true;

  // Implement other required methods with minimal functionality
  @override
  bool? getBool(String key) => null;

  @override
  int? getInt(String key) => null;

  @override
  double? getDouble(String key) => null;

  @override
  List<String>? getStringList(String key) => null;

  @override
  Future<bool> setBool(String key, bool value) async => true;

  @override
  Future<bool> setInt(String key, int value) async => true;

  @override
  Future<bool> setDouble(String key, double value) async => true;

  @override
  Future<bool> setStringList(String key, List<String> value) async => true;

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Object? get(String key) => _data[key];

  @override
  bool? get asBool => null;

  @override
  double? get asDouble => null;

  @override
  int? get asInt => null;

  @override
  String? get asString => null;

  @override
  List<String>? get asStringList => null;

  @override
  Future<void> reload() async {}
}

class EventsRepository implements EventsRepositoryInterface {
  final ApiService _apiService;
  final SharedPreferences _preferences;
  static const String _eventsCacheKey = 'events_cache';
  static const String _eventsTimestampKey = 'events_timestamp';

  EventsRepository(this._apiService, this._preferences);

  // Factory constructor for creating a mock instance for development and testing
  factory EventsRepository.mock() {
    // This is a temporary mock implementation that will work until we can properly inject dependencies
    return EventsRepository._internal();
  }

  // Internal constructor for mock implementation
  EventsRepository._internal()
      : _apiService = ApiService.mock(),
        _preferences = _MockSharedPreferences() {
    // Pre-populate mock cache with test data
    final mockEvents = _getMockEvents();
    _cacheEvents(mockEvents);
  }

  // Get mock events data for development and testing
  List<EventModel> _getMockEvents() {
    final now = DateTime.now();

    return [
      EventModel(
        id: '1',
        title: 'Campus Welcome Week',
        description:
            'Join us for a week of activities to welcome new and returning students to campus.',
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 7)),
        location: 'Various Campus Locations',
        organizer: 'Student Affairs',
        categories: ['Social', 'Featured'],
        imageUrl: 'assets/images/welcome_week.jepg.jpg',
        tags: ['welcome', 'featured', 'social'],
        isVirtual: false,
        category: 'Social',
      ),
      EventModel(
        id: '2',
        title: 'Career Fair',
        description:
            'Connect with employers from various industries and explore career opportunities.',
        startTime: now.add(const Duration(days: 5, hours: 10)),
        endTime: now.add(const Duration(days: 5, hours: 15)),
        location: 'Student Center Ballroom',
        organizer: 'Career Services',
        categories: ['Career', 'Featured'],
        imageUrl: 'assets/images/career_fair.jpeg',
        tags: ['career', 'networking', 'featured'],
        isVirtual: false,
        category: 'Career',
      ),
      EventModel(
        id: '3',
        title: 'Guest Lecture: AI and the Future of Work',
        description:
            'Distinguished speaker Dr. Jane Smith discusses the impact of artificial intelligence on the future job market.',
        startTime: now.add(const Duration(days: 3, hours: 14)),
        endTime: now.add(const Duration(days: 3, hours: 16)),
        location: 'Science Building, Room 101',
        organizer: 'Computer Science Department',
        categories: ['Academic', 'Technology'],
        imageUrl: 'assets/images/guest_lecture.jpeg',
        isVirtual: true,
        virtualLink: 'https://university.zoom.us/j/123456789',
        tags: ['lecture', 'ai', 'technology'],
        category: 'Academic',
      ),
    ];
  }

  // Get all events
  @override
  Future<List<Event>> getAllEvents() async {
    try {
      // Try to use cache first if it's still valid
      if (await _isCacheValid()) {
        final cachedEvents = await _getCachedEvents();
        if (cachedEvents.isNotEmpty) {
          return cachedEvents;
        }
      }

      // Fetch from API
      final response = await _apiService.get(
        '/events',
        useCache: true,
        cacheDuration: const Duration(hours: 3), // Events may change frequently
      );

      final List<dynamic> eventsJson = response['data'] ?? [];
      final List<EventModel> eventModels =
          eventsJson.map((json) => EventModel.fromJson(json)).toList();

      // Save to cache
      await _cacheEvents(eventModels);

      // Convert models to entities before returning
      return eventModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to cache on error
      final cachedEvents = await _getCachedEvents();
      if (cachedEvents.isNotEmpty) {
        return cachedEvents;
      }
      rethrow;
    }
  }

  // Get event by ID
  @override
  Future<Event> getEventById(String id) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.firstWhere(
        (event) => event.id == id,
        orElse: () => throw Exception('Event not found'),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get upcoming events
  @override
  Future<List<Event>> getUpcomingEvents() async {
    try {
      final allEvents = await getAllEvents();
      final now = DateTime.now();
      return allEvents.where((event) => event.startTime.isAfter(now)).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      rethrow;
    }
  }

  // Get events by category
  @override
  Future<List<Event>> getEventsByCategory(String category) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents
          .where((event) => event.categories.contains(category))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get events by date range
  @override
  Future<List<Event>> getEventsByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) {
        return (event.startTime.isAfter(startDate) ||
                event.startTime.isAtSameMomentAs(startDate)) &&
            (event.endTime.isBefore(endDate) ||
                event.endTime.isAtSameMomentAs(endDate));
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add event to personal calendar
  @override
  Future<bool> addToPersonalCalendar(String eventId) async {
    try {
      final event = await getEventById(eventId);
      final response = await _apiService.post(
        '/user/calendar',
        body: {
          'eventId': event.id,
        },
      );
      return response['success'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  // Cache helpers
  Future<void> _cacheEvents(List<EventModel> events) async {
    try {
      final eventsJson = events.map((event) => event.toJson()).toList();
      await _preferences.setString(_eventsCacheKey, json.encode(eventsJson));
      await _preferences.setString(
        _eventsTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching events: $e');
    }
  }

  Future<List<Event>> _getCachedEvents() async {
    try {
      final String? cachedData = _preferences.getString(_eventsCacheKey);
      if (cachedData == null) return [];

      final List<dynamic> eventsJson = json.decode(cachedData);
      final List<EventModel> eventModels =
          eventsJson.map((json) => EventModel.fromJson(json)).toList();
      // Convert models to entities before returning
      return eventModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('Error retrieving cached events: $e');
      return [];
    }
  }

  Future<bool> _isCacheValid() async {
    try {
      final String? timestamp = _preferences.getString(_eventsTimestampKey);
      if (timestamp == null) return false;

      final DateTime cacheTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();

      // Events cache valid for 3 hours
      final bool isValid = now.difference(cacheTime).inHours < 3;
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // Clear cache
  @override
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_eventsCacheKey);
      await _preferences.remove(_eventsTimestampKey);
    } catch (e) {
      print('Error clearing events cache: $e');
    }
  }
}

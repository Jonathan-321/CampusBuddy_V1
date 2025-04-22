import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/api_service.dart';
import '../models/emergency_contact_model.dart';
import '../../domain/entities/emergency_contact.dart';

class EmergencyRepository {
  final ApiService _apiService;
  final SharedPreferences _preferences;
  static const String _emergencyContactsCacheKey = 'emergency_contacts_cache';
  static const String _emergencyContactsTimestampKey = 'emergency_contacts_timestamp';

  EmergencyRepository(this._apiService, this._preferences);

  // Get all emergency contacts
  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    try {
      // Try to use cache first if it's still valid
      if (await _isCacheValid()) {
        final cachedContacts = await _getCachedEmergencyContacts();
        if (cachedContacts.isNotEmpty) {
          return cachedContacts;
        }
      }

      // Fetch from API
      final response = await _apiService.get(
        '/emergency-contacts',
        useCache: true,
        cacheDuration: const Duration(days: 7), // Longer duration for emergency contacts
      );

      final List<dynamic> contactsJson = response['data'] ?? [];
      final List<EmergencyContactModel> contacts = contactsJson
          .map((json) => EmergencyContactModel.fromJson(json))
          .toList();

      // Save to cache
      await _cacheEmergencyContacts(contacts);

      return contacts;
    } catch (e) {
      // Fallback to cache on error
      final cachedContacts = await _getCachedEmergencyContacts();
      if (cachedContacts.isNotEmpty) {
        return cachedContacts;
      }
      rethrow;
    }
  }

  // Get emergency contacts by category
  Future<List<EmergencyContact>> getEmergencyContactsByCategory(String category) async {
    try {
      final allContacts = await getAllEmergencyContacts();
      return allContacts.where((contact) => contact.category == category).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get emergency-only contacts
  Future<List<EmergencyContact>> getEmergencyOnlyContacts() async {
    try {
      final allContacts = await getAllEmergencyContacts();
      return allContacts.where((contact) => contact.isEmergency).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Cache helpers
  Future<void> _cacheEmergencyContacts(List<EmergencyContactModel> contacts) async {
    try {
      final contactsJson = contacts.map((contact) => contact.toJson()).toList();
      await _preferences.setString(_emergencyContactsCacheKey, json.encode(contactsJson));
      await _preferences.setString(
        _emergencyContactsTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching emergency contacts: $e');
    }
  }

  Future<List<EmergencyContact>> _getCachedEmergencyContacts() async {
    try {
      final String? cachedData = _preferences.getString(_emergencyContactsCacheKey);
      if (cachedData == null) return [];

      final List<dynamic> contactsJson = json.decode(cachedData);
      return contactsJson
          .map((json) => EmergencyContactModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error retrieving cached emergency contacts: $e');
      return [];
    }
  }

  Future<bool> _isCacheValid() async {
    try {
      final String? timestamp = _preferences.getString(_emergencyContactsTimestampKey);
      if (timestamp == null) return false;

      final DateTime cacheTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      
      // Emergency contacts cache valid for 7 days
      final bool isValid = now.difference(cacheTime).inDays < 7;
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_emergencyContactsCacheKey);
      await _preferences.remove(_emergencyContactsTimestampKey);
    } catch (e) {
      print('Error clearing emergency contacts cache: $e');
    }
  }
}

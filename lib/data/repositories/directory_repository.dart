import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/api_service.dart';
import '../models/directory_model.dart';
import '../../domain/entities/directory_entry.dart';

class DirectoryRepository {
  final ApiService _apiService;
  final SharedPreferences _preferences;
  static const String _directoryCacheKey = 'directory_cache';
  static const String _directoryTimestampKey = 'directory_timestamp';

  DirectoryRepository(this._apiService, this._preferences);

  // Get all directory entries
  Future<List<DirectoryEntry>> getAllDirectoryEntries() async {
    try {
      // Try to use cache first if it's still valid
      if (await _isCacheValid()) {
        final cachedEntries = await _getCachedDirectoryEntries();
        if (cachedEntries.isNotEmpty) {
          return cachedEntries;
        }
      }

      // Fetch from API
      final response = await _apiService.get(
        '/directory',
        useCache: true,
        cacheDuration: const Duration(days: 1),
      );

      final List<dynamic> entriesJson = response['data'] ?? [];
      final List<DirectoryModel> entries = entriesJson
          .map((json) => DirectoryModel.fromJson(json))
          .toList();

      // Save to cache
      await _cacheDirectoryEntries(entries);

      return entries;
    } catch (e) {
      // Fallback to cache on error
      final cachedEntries = await _getCachedDirectoryEntries();
      if (cachedEntries.isNotEmpty) {
        return cachedEntries;
      }
      rethrow;
    }
  }

  // Search directory entries
  Future<List<DirectoryEntry>> searchDirectory(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllDirectoryEntries();
      }

      final allEntries = await getAllDirectoryEntries();
      final lowercaseQuery = query.toLowerCase();
      
      return allEntries.where((entry) {
        return entry.name.toLowerCase().contains(lowercaseQuery) ||
            entry.department.toLowerCase().contains(lowercaseQuery) ||
            entry.title.toLowerCase().contains(lowercaseQuery) ||
            entry.email.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get directory entries by department
  Future<List<DirectoryEntry>> getEntriesByDepartment(String department) async {
    try {
      final allEntries = await getAllDirectoryEntries();
      return allEntries.where((entry) => entry.department == department).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get directory entry by ID
  Future<DirectoryEntry?> getEntryById(String id) async {
    try {
      final allEntries = await getAllDirectoryEntries();
      return allEntries.firstWhere(
        (entry) => entry.id == id,
        orElse: () => throw Exception('Directory entry not found'),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Cache helpers
  Future<void> _cacheDirectoryEntries(List<DirectoryModel> entries) async {
    try {
      final entriesJson = entries.map((entry) => entry.toJson()).toList();
      await _preferences.setString(_directoryCacheKey, json.encode(entriesJson));
      await _preferences.setString(
        _directoryTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching directory entries: $e');
    }
  }

  Future<List<DirectoryEntry>> _getCachedDirectoryEntries() async {
    try {
      final String? cachedData = _preferences.getString(_directoryCacheKey);
      if (cachedData == null) return [];

      final List<dynamic> entriesJson = json.decode(cachedData);
      return entriesJson
          .map((json) => DirectoryModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error retrieving cached directory entries: $e');
      return [];
    }
  }

  Future<bool> _isCacheValid() async {
    try {
      final String? timestamp = _preferences.getString(_directoryTimestampKey);
      if (timestamp == null) return false;

      final DateTime cacheTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      
      // Directory cache valid for 1 day
      final bool isValid = now.difference(cacheTime).inHours < 24;
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_directoryCacheKey);
      await _preferences.remove(_directoryTimestampKey);
    } catch (e) {
      print('Error clearing directory cache: $e');
    }
  }
}

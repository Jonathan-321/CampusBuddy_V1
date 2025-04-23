import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to load and manage university data
class UniversityDataService {
  // The in-memory cache of university data
  Map<String, dynamic>? _universityData;

  // Path to university data file
  static const String _dataFilePath = 'assets/data/university_data.json';

  // Cache key for SharedPreferences
  static const String _cacheKey = 'university_data_cache';

  // Singleton instance
  static UniversityDataService? _instance;

  // Private constructor
  UniversityDataService._();

  /// Get singleton instance
  static UniversityDataService get instance {
    _instance ??= UniversityDataService._();
    return _instance!;
  }

  /// Load university data from assets file
  Future<Map<String, dynamic>> getUniversityData() async {
    // Return cached data if available
    if (_universityData != null) {
      return _universityData!;
    }

    try {
      // Try to load from SharedPreferences cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        _universityData = json.decode(cachedData) as Map<String, dynamic>;
        return _universityData!;
      }

      // Load from asset file if not in cache
      final jsonString = await rootBundle.loadString(_dataFilePath);
      _universityData = json.decode(jsonString) as Map<String, dynamic>;

      // Cache the data
      await prefs.setString(_cacheKey, jsonString);

      return _universityData!;
    } catch (e) {
      throw Exception('Failed to load university data: $e');
    }
  }

  /// Reload data from asset file (force refresh)
  Future<Map<String, dynamic>> reloadUniversityData() async {
    try {
      // Load from asset file
      final jsonString = await rootBundle.loadString(_dataFilePath);
      _universityData = json.decode(jsonString) as Map<String, dynamic>;

      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonString);

      return _universityData!;
    } catch (e) {
      throw Exception('Failed to reload university data: $e');
    }
  }

  /// Clear cached data
  Future<void> clearCache() async {
    _universityData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}

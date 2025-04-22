import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/api_service.dart';
import '../models/dining_model.dart';
import '../../domain/entities/dining_info.dart';

class DiningRepository {
  final ApiService _apiService;
  final SharedPreferences _preferences;
  static const String _diningCacheKey = 'dining_cache';
  static const String _diningTimestampKey = 'dining_timestamp';

  DiningRepository(this._apiService, this._preferences);

  // Get all dining options
  Future<List<DiningInfo>> getAllDiningOptions() async {
    try {
      // Try to use cache first if it's still valid
      if (await _isCacheValid()) {
        final cachedOptions = await _getCachedDiningOptions();
        if (cachedOptions.isNotEmpty) {
          return cachedOptions;
        }
      }

      // Fetch from API
      final response = await _apiService.get(
        '/dining',
        useCache: true,
        cacheDuration: const Duration(hours: 6), // Refresh multiple times a day for menu changes
      );

      final List<dynamic> optionsJson = response['data'] ?? [];
      final List<DiningInfoModel> options = optionsJson
          .map((json) => DiningInfoModel.fromJson(json))
          .toList();

      // Save to cache
      await _cacheDiningOptions(options);

      return options;
    } catch (e) {
      // Fallback to cache on error
      final cachedOptions = await _getCachedDiningOptions();
      if (cachedOptions.isNotEmpty) {
        return cachedOptions;
      }
      rethrow;
    }
  }

  // Get dining option by ID
  Future<DiningInfo> getDiningOptionById(String id) async {
    try {
      final allOptions = await getAllDiningOptions();
      return allOptions.firstWhere(
        (option) => option.id == id,
        orElse: () => throw Exception('Dining option not found'),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get dining options that accept meal plan
  Future<List<DiningInfo>> getMealPlanOptions() async {
    try {
      final allOptions = await getAllDiningOptions();
      return allOptions.where((option) => option.acceptsMealPlan).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search menu items
  Future<Map<String, List<MenuItem>>> searchMenuItems(String query) async {
    try {
      if (query.isEmpty) {
        return {};
      }

      final allOptions = await getAllDiningOptions();
      final lowercaseQuery = query.toLowerCase();
      final Map<String, List<MenuItem>> results = {};
      
      for (final option in allOptions) {
        final matchingItems = option.menu.where((item) {
          return item.name.toLowerCase().contains(lowercaseQuery) ||
              item.description.toLowerCase().contains(lowercaseQuery) ||
              item.category.toLowerCase().contains(lowercaseQuery) ||
              item.dietaryInfo.any((info) => info.toLowerCase().contains(lowercaseQuery));
        }).toList();
        
        if (matchingItems.isNotEmpty) {
          results[option.name] = matchingItems;
        }
      }
      
      return results;
    } catch (e) {
      rethrow;
    }
  }

  // Cache helpers
  Future<void> _cacheDiningOptions(List<DiningInfoModel> options) async {
    try {
      final optionsJson = options.map((option) => option.toJson()).toList();
      await _preferences.setString(_diningCacheKey, json.encode(optionsJson));
      await _preferences.setString(
        _diningTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching dining options: $e');
    }
  }

  Future<List<DiningInfo>> _getCachedDiningOptions() async {
    try {
      final String? cachedData = _preferences.getString(_diningCacheKey);
      if (cachedData == null) return [];

      final List<dynamic> optionsJson = json.decode(cachedData);
      return optionsJson
          .map((json) => DiningInfoModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error retrieving cached dining options: $e');
      return [];
    }
  }

  Future<bool> _isCacheValid() async {
    try {
      final String? timestamp = _preferences.getString(_diningTimestampKey);
      if (timestamp == null) return false;

      final DateTime cacheTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      
      // Dining cache valid for 6 hours
      final bool isValid = now.difference(cacheTime).inHours < 6;
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_diningCacheKey);
      await _preferences.remove(_diningTimestampKey);
    } catch (e) {
      print('Error clearing dining cache: $e');
    }
  }
}

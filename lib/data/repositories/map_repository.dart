import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/api_service.dart';
import '../models/map_location_model.dart';
import '../../domain/entities/map_location.dart';
import 'dart:math';

class MapRepository {
  final ApiService _apiService;
  final SharedPreferences _preferences;
  static const String _locationsCacheKey = 'map_locations_cache';
  static const String _locationsTimestampKey = 'map_locations_timestamp';

  MapRepository(this._apiService, this._preferences);

  // Get all map locations
  Future<List<MapLocation>> getAllLocations() async {
    try {
      // Try to use cache first if it's still valid
      if (await _isCacheValid()) {
        final cachedLocations = await _getCachedLocations();
        if (cachedLocations.isNotEmpty) {
          return cachedLocations;
        }
      }

      // Fetch from API
      final response = await _apiService.get(
        '/map/locations',
        useCache: true,
        cacheDuration:
            const Duration(days: 7), // Map locations don't change often
      );

      final List<dynamic> locationsJson = response['data'] ?? [];
      final List<MapLocationModel> locations =
          locationsJson.map((json) => MapLocationModel.fromJson(json)).toList();

      // Save to cache
      await _cacheLocations(locations);

      return locations;
    } catch (e) {
      // Fallback to cache on error
      final cachedLocations = await _getCachedLocations();
      if (cachedLocations.isNotEmpty) {
        return cachedLocations;
      }
      rethrow;
    }
  }

  // Get location by ID
  Future<MapLocation> getLocationById(String id) async {
    try {
      final allLocations = await getAllLocations();
      return allLocations.firstWhere(
        (location) => location.id == id,
        orElse: () => throw Exception('Location not found'),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get locations by category
  Future<List<MapLocation>> getLocationsByCategory(String category) async {
    try {
      final allLocations = await getAllLocations();
      return allLocations
          .where((location) => location.category == category)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search locations
  Future<List<MapLocation>> searchLocations(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllLocations();
      }

      final allLocations = await getAllLocations();
      final lowercaseQuery = query.toLowerCase();

      return allLocations.where((location) {
        return location.name.toLowerCase().contains(lowercaseQuery) ||
            location.description.toLowerCase().contains(lowercaseQuery) ||
            location.category.toLowerCase().contains(lowercaseQuery) ||
            location.facilities.any(
                (facility) => facility.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get nearby locations
  Future<List<MapLocation>> getNearbyLocations(
      LatLng userLocation, double radiusInMeters) async {
    try {
      final allLocations = await getAllLocations();

      return allLocations.where((location) {
        // Calculate distance using the Haversine formula
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          location.latitude,
          location.longitude,
        );

        return distance <= radiusInMeters;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Helper function to calculate distance using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // in meters

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Cache helpers
  Future<void> _cacheLocations(List<MapLocationModel> locations) async {
    try {
      final locationsJson =
          locations.map((location) => location.toJson()).toList();
      await _preferences.setString(
          _locationsCacheKey, json.encode(locationsJson));
      await _preferences.setString(
        _locationsTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error caching map locations: $e');
    }
  }

  Future<List<MapLocation>> _getCachedLocations() async {
    try {
      final String? cachedData = _preferences.getString(_locationsCacheKey);
      if (cachedData == null) return [];

      final List<dynamic> locationsJson = json.decode(cachedData);
      return locationsJson
          .map((json) => MapLocationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error retrieving cached map locations: $e');
      return [];
    }
  }

  Future<bool> _isCacheValid() async {
    try {
      final String? timestamp = _preferences.getString(_locationsTimestampKey);
      if (timestamp == null) return false;

      final DateTime cacheTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();

      // Map locations cache valid for 7 days
      final bool isValid = now.difference(cacheTime).inDays < 7;
      return isValid;
    } catch (e) {
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _preferences.remove(_locationsCacheKey);
      await _preferences.remove(_locationsTimestampKey);
    } catch (e) {
      print('Error clearing map locations cache: $e');
    }
  }
}

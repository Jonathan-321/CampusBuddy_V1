import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

class AuthRepository {
  final FirebaseService _firebaseService;
  final SharedPreferences _preferences;
  static const String _userCacheKey = 'cached_user';

  AuthRepository(this._firebaseService, this._preferences);

  // Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );
      _cacheUserLocally(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Create a new user with email and password
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final user = await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );
      _cacheUserLocally(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      final user = await _firebaseService.signInWithGoogle();
      _cacheUserLocally(user);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      await _clearUserCache();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  Future<User> getCurrentUser() async {
    try {
      // Try to get the user from Firebase first
      final user = await _firebaseService.getCurrentUser();
      
      // If the user is authenticated, return and cache
      if (user.isAuthenticated) {
        _cacheUserLocally(user);
        return user;
      }
      
      // If not authenticated, try to get from cache
      final cachedUser = _getCachedUser();
      return cachedUser ?? user;
    } catch (e) {
      // Fallback to cached user on error
      final cachedUser = _getCachedUser();
      return cachedUser ?? UserModel.empty();
    }
  }

  // Get auth state changes stream
  Stream<User> get authStateChanges => _firebaseService.authStateChanges;

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Local caching methods
  Future<void> _cacheUserLocally(UserModel user) async {
    if (user.isAuthenticated) {
      await _preferences.setString(_userCacheKey, jsonEncode(user.toJson()));
    }
  }

  UserModel? _getCachedUser() {
    final userJson = _preferences.getString(_userCacheKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('Error parsing cached user: $e');
      }
    }
    return null;
  }

  Future<void> _clearUserCache() async {
    await _preferences.remove(_userCacheKey);
  }
}

// Helper function for JSON serialization
dynamic jsonEncode(dynamic item) {
  if (item is Map) {
    return item;
  }
  return item;
}

// Helper function for JSON deserialization
dynamic jsonDecode(dynamic item) {
  if (item is String) {
    return Map<String, dynamic>.from(
      Map.castFrom(item as Map<dynamic, dynamic>)
    );
  }
  return item;
}

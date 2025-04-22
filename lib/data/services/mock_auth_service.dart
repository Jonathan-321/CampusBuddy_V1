import 'package:campus_buddy/data/models/user_model.dart';

class MockAuthService {
  // Singleton pattern
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // Mock user data
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  // Get current user
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Login with email and password
  Future<UserModel> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For testing, accept any email with a valid format and any password with length >= 6
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid email or password');
    }
    
    // Create a mock user
    _currentUser = UserModel(
      id: 'mock-user-id',
      email: email,
      displayName: email.split('@')[0],
      photoUrl: 'https://ui-avatars.com/api/?name=${email.split('@')[0]}',
      isEmailVerified: true,
    );
    
    _isAuthenticated = true;
    return _currentUser!;
  }

  // Register with email, password, and name
  Future<UserModel> register(String email, String password, String name) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For testing, accept any email with a valid format and any password with length >= 6
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid email or password');
    }
    
    // Create a mock user
    _currentUser = UserModel(
      id: 'mock-user-id',
      email: email,
      displayName: name,
      photoUrl: 'https://ui-avatars.com/api/?name=$name',
      isEmailVerified: false,
    );
    
    _isAuthenticated = true;
    return _currentUser!;
  }

  // Sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _isAuthenticated = false;
  }

  // Check if user is authenticated
  Future<bool> checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _isAuthenticated;
  }
}

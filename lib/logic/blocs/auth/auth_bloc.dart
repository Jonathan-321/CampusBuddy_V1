import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/mock_auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignedOut extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final bool isRegistering;

  const LoggedIn({
    required this.email, 
    required this.password, 
    this.name,
    this.isRegistering = false,
  });

  @override
  List<Object?> get props => [email, password, name, isRegistering];
}

class SignedUp extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignedUp({
    required this.email, 
    required this.password, 
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class UserUpdated extends AuthEvent {
  final UserModel user;

  const UserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MockAuthService _authService = MockAuthService();
  
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoggedIn>(_onLoggedIn);
    on<SignedUp>(_onSignedUp);
    on<SignedOut>(_onSignedOut);
    on<UserUpdated>(_onUserUpdated);
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final isAuthenticated = await _authService.checkAuth();
    
    if (isAuthenticated && _authService.currentUser != null) {
      emit(Authenticated(user: _authService.currentUser!));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // In a real app, we would call an authentication service
      // For now, we'll just simulate a successful login or registration
      await Future.delayed(const Duration(seconds: 1));
      
      if (event.isRegistering) {
        // Handle registration
        final user = UserModel(
          id: '1',
          email: event.email,
          displayName: event.name ?? 'New User',
          photoUrl: null,
          isEmailVerified: false,
        );
        
        emit(Authenticated(user: user));
      } else {
        // Handle login
        final user = UserModel(
          id: '1',
          email: event.email,
          displayName: 'Test User',
          photoUrl: null,
          isEmailVerified: true,
        );
        
        emit(Authenticated(user: user));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onSignedUp(SignedUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // In a real app, we would call an authentication service
      // For now, we'll just simulate a successful signup
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock user
      final user = UserModel(
        id: '1',
        email: event.email,
        displayName: event.displayName ?? 'New User',
        photoUrl: null,
        isEmailVerified: false,
      );
      
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onSignedOut(SignedOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      // In a real app, we would call an authentication service
      // For now, we'll just simulate a successful logout
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) {
    emit(Authenticated(user: event.user));
  }
}

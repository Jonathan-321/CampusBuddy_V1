import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInWithEmailPasswordRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailPasswordRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogleRequested extends AuthEvent {}

class SignUpWithEmailPasswordRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpWithEmailPasswordRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthStateChanged extends AuthEvent {
  final User user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}

import '../../domain/entities/user_entity.dart';

/// Possible states for the authentication flow.
sealed class AuthState {
  const AuthState();
}

/// Initial state, not yet attempting any auth.
class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

/// Currently loading an auth operation.
class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

/// User is authenticated.
class AuthStateAuthenticated extends AuthState {
  final UserEntity user;
  const AuthStateAuthenticated(this.user);
}

/// User is unauthenticated but has seen onboarding.
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// An error occurred during auth.
class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}
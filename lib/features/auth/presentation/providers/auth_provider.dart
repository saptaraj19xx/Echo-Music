import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Provider for the auth repository instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for the authentication state.
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Notifier managing authentication state.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthStateInitial());

  /// Check if the user is already authenticated (for app startup).
  Future<void> checkAuthStatus() async {
    state = const AuthStateLoading();
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => state = AuthStateError(failure.message),
      (user) {
        if (user != null) {
          state = AuthStateAuthenticated(user);
        } else {
          state = const AuthStateUnauthenticated();
        }
      },
    );
  }

  /// Sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    final result = await _repository.signIn(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = AuthStateError(failure.message),
      (user) => state = AuthStateAuthenticated(user),
    );
  }

  /// Create a new account.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    final result = await _repository.signUp(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => state = AuthStateError(failure.message),
      (user) => state = AuthStateAuthenticated(user),
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    state = const AuthStateLoading();
    final result = await _repository.signOut();
    result.fold(
      (failure) => state = AuthStateError(failure.message),
      (_) => state = const AuthStateUnauthenticated(),
    );
  }

  /// Send forgot password email.
  Future<String?> forgotPassword({required String email}) async {
    final result = await _repository.forgotPassword(email: email);
    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }

  /// Continue as guest.
  Future<void> continueAsGuest() async {
    state = const AuthStateLoading();
    final result = await _repository.continueAsGuest();
    result.fold(
      (failure) => state = AuthStateError(failure.message),
      (user) => state = AuthStateAuthenticated(user),
    );
  }

  /// Clear error state and return to unauthenticated.
  void clearError() {
    state = const AuthStateUnauthenticated();
  }
}
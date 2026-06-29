import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/auth_exception.dart';
import '../../../../core/firebase/auth_adapter.dart';

/// Mock authentication data source.
///
/// Sprint 12 Phase 2: now delegates to Firebase Authentication.
class MockAuthDataSource {
  MockAuthDataSource({AuthAdapter? authAdapter})
      : _authAdapter = authAdapter ?? AuthAdapter();

  final AuthAdapter _authAdapter;


  /// Sign in with email and password.
  Future<MockUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _authAdapter.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toMockUser(cred.user);
    } on FirebaseAuthException catch (e) {
      throw AuthAdapter.mapAuthError(e);
    }
  }

  /// Create a new account with email and password.
  Future<MockUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _authAdapter.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toMockUser(cred.user);
    } on FirebaseAuthException catch (e) {
      throw AuthAdapter.mapAuthError(e);
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    try {
      await _authAdapter.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthAdapter.mapAuthError(e);
    }
  }

  /// Send password reset email.
  Future<void> forgotPassword({required String email}) async {
    try {
      await _authAdapter.forgotPassword(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthAdapter.mapAuthError(e);
    }
  }

  /// Guest sign-in using Firebase anonymous authentication.
  Future<MockUser> continueAsGuest() async {
    // TEMP DIAGNOSTICS: identify exact failing step (do not keep)
    // 1) before calling AuthAdapter.signInAsGuest()
    // ignore: avoid_print
    print('[DIAG] MockAuthDataSource.continueAsGuest(): before signInAsGuest');

    try {
      // 2) immediately after AuthAdapter.signInAsGuest() returns
      final cred = await _authAdapter.signInAsGuest();

      // ignore: avoid_print
      print('[DIAG] MockAuthDataSource.continueAsGuest(): after signInAsGuest (returned)');

      // 3) before calling _toMockUser(...)
      // ignore: avoid_print
      print('[DIAG] MockAuthDataSource.continueAsGuest(): before _toMockUser');

      final mockUser = _toMockUser(cred.user, isGuestOverride: true);

      // 4) after _toMockUser(...)
      // ignore: avoid_print
      print('[DIAG] MockAuthDataSource.continueAsGuest(): after _toMockUser');

      // 5) before returning to AuthRepository
      // ignore: avoid_print
      print('[DIAG] MockAuthDataSource.continueAsGuest(): returning MockUser');

      return mockUser;
    } on FirebaseAuthException catch (e) {
      throw AuthAdapter.mapAuthError(e);
    }
  }


  /// Get current user.
  Future<MockUser?> getCurrentUser() async {
    try {
      final user = await _authAdapter.currentUser();
      if (user == null) return null;
      return _toMockUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthAdapter.mapAuthError(e);
    }
  }

  MockUser _toMockUser(User? user, {bool isGuestOverride = false}) {
    if (user == null) {
      // This should only happen if Firebase actually returned no user.
      throw const AuthException(
        code: AuthException.unknown,
        message: 'Authentication failed: missing user.',
      );
    }

    final email = user.email;

    return MockUser(
      id: user.uid,
      // Anonymous users often have null email; that's not a failure.
      email: email ?? '',
      // Password is not retrievable from Firebase; keep empty.
      password: '',
      displayName: user.displayName ?? (email?.split('@').first ?? ''),
      photoUrl: user.photoURL,
      isGuest: isGuestOverride || user.isAnonymous,
    );
  }
}

/// Internal user representation consumed by existing AuthRepository.
class MockUser {
  final String id;
  final String email;
  final String password;
  final String displayName;
  final String? photoUrl;
  final bool isGuest;

  const MockUser({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
    this.photoUrl,
    this.isGuest = false,
  });
}


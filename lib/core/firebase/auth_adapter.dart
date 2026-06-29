import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/auth_exception.dart';
import 'oauth_config_exception.dart';

/// Auth adapter that hides FirebaseAuth from repositories.
class AuthAdapter {
  AuthAdapter({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> currentUser() async => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> forgotPassword({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Guest login via Firebase anonymous auth.
  Future<UserCredential> signInAsGuest() async {
    // TEMP DIAGNOSTICS: identify exact failing step (do not keep)
    // 1) before FirebaseAuth.instance.signInAnonymously()
    // ignore: avoid_print
    print('[DIAG] AuthAdapter.signInAsGuest(): before signInAnonymously');

    try {
      final cred = await _auth
          .signInAnonymously()
          .timeout(const Duration(seconds: 10));

      // 2) immediately after signInAnonymously() returns
      // ignore: avoid_print
      print('[DIAG] AuthAdapter.signInAsGuest(): after signInAnonymously (returned)');

      return cred;
    } on TimeoutException {
      // ignore: avoid_print
      print('[DIAG] AuthAdapter.signInAsGuest(): signInAnonymously timed out');
      rethrow;
    } on Object {
      // ignore: avoid_print
      print('[DIAG] AuthAdapter.signInAsGuest(): signInAnonymously threw');
      rethrow;
    }
  }


  /// Google sign-in using OAuth.
  ///
  /// NOTE: google_sign_in plugin is not currently present in pubspec.yaml, so
  /// this method returns a configuration error rather than crashing.
  Future<UserCredential> signInWithGoogle() async {
    throw OAuthConfigException(
      code: AuthException.operationNotAllowed,
      message:
          'Google Sign-In requires the google_sign_in plugin and platform OAuth configuration. Add google_sign_in and configure SHA keys / OAuth client IDs.',
    );
  }

  /// Maps [FirebaseAuthException] into the domain [AuthException].
  static AuthException mapAuthError(FirebaseAuthException e) {
    final code = e.code;

    switch (code) {
      case 'invalid-email':
        return const AuthException(
          code: AuthException.invalidEmail,
          message: 'Invalid email address.',
        );
      case 'user-not-found':
        return const AuthException(
          code: AuthException.userNotFound,
          message: 'No account found with this email address.',
        );
      case 'wrong-password':
        return const AuthException(
          code: AuthException.wrongPassword,
          message: 'Incorrect password. Please try again.',
        );
      case 'email-already-in-use':
        return const AuthException(
          code: AuthException.emailAlreadyInUse,
          message: 'An account with this email already exists.',
        );
      case 'weak-password':
        return const AuthException(
          code: AuthException.weakPassword,
          message: 'Password is too weak.',
        );
      case 'too-many-requests':
        return const AuthException(
          code: AuthException.tooManyRequests,
          message: 'Too many requests. Please try again later.',
        );
      case 'network-request-failed':
        return const AuthException(
          code: AuthException.networkError,
          message: 'Network error. Please check your connection.',
        );
      case 'operation-not-allowed':
        return const AuthException(
          code: AuthException.operationNotAllowed,
          message: 'This operation is not allowed right now.',
        );
      default:
        return AuthException(
          code: AuthException.unknown,
          message: e.message ?? 'Authentication failed.',
        );
    }
  }
}




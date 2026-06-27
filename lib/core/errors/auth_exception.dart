/// Custom exception for authentication errors.
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AuthException($code): $message';

  // Common error codes
  static const String invalidEmail = 'invalid-email';
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String tooManyRequests = 'too-many-requests';
  static const String networkError = 'network-error';
  static const String unknown = 'unknown';
  static const String operationNotAllowed = 'operation-not-allowed';
}
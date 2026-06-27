import '../errors/auth_exception.dart';

/// Thrown when Google Sign-In (OAuth) configuration is incomplete.
class OAuthConfigException extends AuthException {
  OAuthConfigException({
    required super.code,
    required super.message,
  });
}


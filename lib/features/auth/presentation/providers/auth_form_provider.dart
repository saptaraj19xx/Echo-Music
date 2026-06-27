import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Validation result for a form field.
class FieldValidation {
  final bool isValid;
  final String? errorMessage;

  const FieldValidation({required this.isValid, this.errorMessage});

  static const FieldValidation valid = FieldValidation(isValid: true);

  factory FieldValidation.invalid(String message) =>
      FieldValidation(isValid: false, errorMessage: message);
}

/// Provider for authentication form validation state.
final authFormProvider =
    StateNotifierProvider<AuthFormNotifier, AuthFormState>((ref) {
  return AuthFormNotifier();
});

/// State for the auth form fields and validation.
class AuthFormState {
  final String email;
  final String password;
  final String confirmPassword;
  final String name;
  final FieldValidation emailValidation;
  final FieldValidation passwordValidation;
  final FieldValidation confirmPasswordValidation;
  final FieldValidation nameValidation;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const AuthFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.name = '',
    this.emailValidation = FieldValidation.valid,
    this.passwordValidation = FieldValidation.valid,
    this.confirmPasswordValidation = FieldValidation.valid,
    this.nameValidation = FieldValidation.valid,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  AuthFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? name,
    FieldValidation? emailValidation,
    FieldValidation? passwordValidation,
    FieldValidation? confirmPasswordValidation,
    FieldValidation? nameValidation,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      name: name ?? this.name,
      emailValidation: emailValidation ?? this.emailValidation,
      passwordValidation: passwordValidation ?? this.passwordValidation,
      confirmPasswordValidation:
          confirmPasswordValidation ?? this.confirmPasswordValidation,
      nameValidation: nameValidation ?? this.nameValidation,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }

  /// Whether all required fields are valid for sign-in.
  bool get isSignInValid =>
      emailValidation.isValid &&
      passwordValidation.isValid &&
      email.isNotEmpty &&
      password.isNotEmpty;

  /// Whether all required fields are valid for sign-up.
  bool get isSignUpValid =>
      emailValidation.isValid &&
      passwordValidation.isValid &&
      confirmPasswordValidation.isValid &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;

  /// Whether all required fields are valid for forgot password.
  bool get isForgotPasswordValid =>
      emailValidation.isValid && email.isNotEmpty;
}

/// Notifier for auth form validation.
class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier() : super(const AuthFormState());

  /// Email validation regex.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Update email and validate.
  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      emailValidation: _validateEmail(value),
    );
  }

  /// Update password and validate.
  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      passwordValidation: _validatePassword(value),
    );
    // Re-validate confirm password if it has a value.
    if (state.confirmPassword.isNotEmpty) {
      state = state.copyWith(
        confirmPasswordValidation:
            _validateConfirmPassword(state.confirmPassword, value),
      );
    }
  }

  /// Update confirm password and validate.
  void setConfirmPassword(String value) {
    state = state.copyWith(
      confirmPassword: value,
      confirmPasswordValidation:
          _validateConfirmPassword(value, state.password),
    );
  }

  /// Update name and validate.
  void setName(String value) {
    state = state.copyWith(
      name: value,
      nameValidation: _validateName(value),
    );
  }

  /// Toggle password visibility.
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  /// Toggle confirm password visibility.
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  /// Reset form to initial state.
  void reset() {
    state = const AuthFormState();
  }

  FieldValidation _validateEmail(String value) {
    if (value.isEmpty) return FieldValidation.valid;
    if (!_emailRegex.hasMatch(value)) {
      return FieldValidation.invalid('Please enter a valid email address.');
    }
    return FieldValidation.valid;
  }

  FieldValidation _validatePassword(String value) {
    if (value.isEmpty) return FieldValidation.valid;
    if (value.length < 8) {
      return FieldValidation.invalid(
          'Password must be at least 8 characters.');
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return FieldValidation.invalid(
          'Password must contain at least one uppercase letter.');
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return FieldValidation.invalid(
          'Password must contain at least one lowercase letter.');
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return FieldValidation.invalid(
          'Password must contain at least one number.');
    }
    return FieldValidation.valid;
  }

  FieldValidation _validateConfirmPassword(String value, String password) {
    if (value.isEmpty) return FieldValidation.valid;
    if (value != password) {
      return FieldValidation.invalid('Passwords do not match.');
    }
    return FieldValidation.valid;
  }

  FieldValidation _validateName(String value) {
    if (value.isEmpty) return FieldValidation.valid;
    if (value.length < 2) {
      return FieldValidation.invalid(
          'Name must be at least 2 characters.');
    }
    return FieldValidation.valid;
  }
}
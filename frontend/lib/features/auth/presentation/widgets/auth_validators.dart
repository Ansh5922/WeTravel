/// Client-side validation matching the existing backend authentication contract.
class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _usernameRegExp = RegExp(
    r'^[a-zA-Z0-9_]{3,50}$',
  );

  /// Validates email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates password (min 8 chars as enforced by backend).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    return null;
  }

  /// Validates username (3-50 chars, alphanumeric + underscore).
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required.';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3 || trimmed.length > 50) {
      return 'Username must be 3–50 characters long.';
    }
    if (!_usernameRegExp.hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, and underscores.';
    }
    return null;
  }
}

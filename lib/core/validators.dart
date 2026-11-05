class AppValidators {
  /// Validates email format. Returns error key if invalid, or null if valid.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'fieldRequired';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'emailInvalid';
    }
    return null;
  }

  /// Validates password length (at least 6 characters). Returns error key if invalid, or null if valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'fieldRequired';
    }
    if (value.length < 6) {
      return 'passwordTooShort';
    }
    return null;
  }

  /// Validates that input is a positive number (> 0). Returns error key if invalid, or null if valid.
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'fieldRequired';
    }
    final number = double.tryParse(value.trim().replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return 'positiveNumberRequired';
    }
    return null;
  }
}

/// Backward compatibility alias
typedef Validators = AppValidators;

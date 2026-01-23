/// Input validation utilities.
///
/// Provides reusable validation functions for form fields.
abstract final class Validators {
  /// Email regex pattern.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone regex pattern (Egyptian format).
  static final _phoneRegex = RegExp(r'^01[0125][0-9]{8}$');

  /// Validates if string is not empty.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  /// Validates password (minimum 6 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  /// Validates phone number (Egyptian format).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  /// Validates minimum length.
  static String? minLength(String? value, int min, [String? fieldName]) {
    if (value == null || value.length < min) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $min أحرف على الأقل';
    }
    return null;
  }

  /// Validates maximum length.
  static String? maxLength(String? value, int max, [String? fieldName]) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'هذا الحقل'} يجب ألا يتجاوز $max أحرف';
    }
    return null;
  }

  /// Validates numeric input.
  static String? numeric(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقماً';
    }
    return null;
  }

  /// Validates positive number.
  static String? positiveNumber(String? value, [String? fieldName]) {
    final numericError = numeric(value, fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '${fieldName ?? 'الرقم'} يجب أن يكون أكبر من صفر';
    }
    return null;
  }

  /// Combines multiple validators.
  static String? combine(
      String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}

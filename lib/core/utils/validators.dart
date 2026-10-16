import 'package:flutter/services.dart';

class Validators {
  static const int minPasswordLength = 8;

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? businessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner or business name is required';
    }
    if (value.trim().length < 2) return 'Enter your name or business name';
    return null;
  }

  /// Pakistani mobile number, e.g. 03XX XXXXXXX (spaces and dashes allowed).
  static String? phone(String? value) {
    final p = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (p.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^03\d{9}$').hasMatch(p)) {
      return 'Enter a valid number like 03XX XXXXXXX';
    }
    return null;
  }

  static final List<TextInputFormatter> phoneFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
    LengthLimitingTextInputFormatter(12),
  ];

  static String? username(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Username is required';
    if (v.length < 3) return 'Username must be at least 3 characters';
    if (v.length > 30) return 'Username can be at most 30 characters';
    if (!RegExp(r'^[a-z0-9._]+$').hasMatch(v)) {
      return 'Use only letters, numbers, periods and underscores';
    }
    if (v.startsWith('.') || v.endsWith('.')) {
      return 'Username cannot start or end with a period';
    }
    if (v.contains('..')) return 'Username cannot have two periods in a row';
    return null;
  }

  /// Instagram-style: only a-z, 0-9, "." and "_", always lowercase.
  static final List<TextInputFormatter> usernameFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
    TextInputFormatter.withFunction(
      (oldValue, newValue) =>
          newValue.copyWith(text: newValue.text.toLowerCase()),
    ),
    LengthLimitingTextInputFormatter(30),
  ];

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Add an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Add a lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Add a number';
    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(value)) {
      return 'Add a special character (e.g. @ # \$ !)';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  /// Login only checks that something was entered.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }
}

import 'package:flutter/material.dart';

/// Theme seed constants.
///
/// Must follow:
/// - Keep this file minimal and stable.
/// - Expose only seed-level constants needed by `ColorScheme.fromSeed`.
///
/// Forbidden:
/// - Defining derived role colors (`onPrimary`, `onSecondary`, etc.).
/// - Holding per-state semantic colors (success/warning/info) here.
/// - Using this as a replacement for `ColorScheme`.
class AppColors {
  const AppColors._();

  /// Material 3 seed color for generating [ColorScheme] via `fromSeed`.
  static const Color primary = Color(0xFF7B1E4A);
  static const Color secondary = Color(0xFFA33D6B);
  static const Color tertiary = Color(0xFFC06C84);
}

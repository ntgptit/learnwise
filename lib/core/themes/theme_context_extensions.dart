import 'package:flutter/material.dart';

/// BuildContext shortcuts for theme access.
///
/// Must follow:
/// - Expose only read-only convenience getters.
/// - Keep getters thin wrappers over `Theme.of(context)`.
///
/// Forbidden:
/// - Business logic/state mutations in extensions.
/// - Theme fallback behavior that diverges from Flutter defaults.
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  Brightness get brightness => theme.brightness;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => theme.textTheme;
}

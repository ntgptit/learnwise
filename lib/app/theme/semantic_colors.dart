import 'package:flutter/material.dart';

const Color _successContainerLight = Color(0xFFD1F4E0);
const Color _successContainerDark = Color(0xFF0D5028);
const Color _onSuccessContainerLight = Color(0xFF002111);
const Color _onSuccessContainerDark = Color(0xFFB3ECC8);
const Color _warningContainerLight = Color(0xFFFFE0B2);
const Color _warningContainerDark = Color(0xFF5C3800);
const Color _onWarningContainerLight = Color(0xFF2E1500);
const Color _onWarningContainerDark = Color(0xFFFFDCC1);
const Color _infoContainerLight = Color(0xFFD0E4FF);
const Color _infoContainerDark = Color(0xFF004A77);
const Color _onInfoContainerLight = Color(0xFF001D35);
const Color _onInfoContainerDark = Color(0xFFADCAFA);

Color _resolveByBrightness({
  required Brightness brightness,
  required Color lightColor,
  required Color darkColor,
}) {
  return switch (brightness) {
    Brightness.light => lightColor,
    Brightness.dark => darkColor,
  };
}

/// Extension on [ColorScheme] to provide semantic colors for success, warning, and info states.
///
/// Material 3 ColorScheme includes built-in support for primary, secondary, and error colors,
/// but doesn't include semantic colors for success, warning, and info states.
/// This extension adds these semantic color roles with proper container/on-container pairs
/// for both light and dark themes.
///
/// Usage:
/// ```dart
/// final colorScheme = Theme.of(context).colorScheme;
///
/// Container(
///   color: colorScheme.successContainer,
///   child: Text(
///     'Success message',
///     style: TextStyle(color: colorScheme.onSuccessContainer),
///   ),
/// )
/// ```
///
/// Color Roles:
/// - **Success**: Green tones for positive states (completed, verified, correct)
/// - **Warning**: Orange tones for caution states (pending, review needed)
/// - **Info**: Blue tones for informational states (tips, notifications)
///
/// Each role has two colors:
/// - `{role}Container`: Background color for the container
/// - `on{role}Container`: Foreground/text color that contrasts with the container
extension SemanticColors on ColorScheme {
  // ==================== SUCCESS COLORS ====================

  /// Background color for success containers.
  ///
  /// Use this for backgrounds of success messages, chips, badges, or cards.
  /// - Light mode: Light green (pastel)
  /// - Dark mode: Dark green
  Color get successContainer {
    return _resolveByBrightness(
      brightness: brightness,
      lightColor: _successContainerLight,
      darkColor: _successContainerDark,
    );
  }

  /// Foreground/text color for content on success containers.
  ///
  /// Use this for text, icons, or other foreground elements on [successContainer].
  /// Ensures proper contrast and readability.
  /// - Light mode: Very dark green (almost black)
  /// - Dark mode: Light green
  Color get onSuccessContainer {
    return _resolveByBrightness(
      brightness: brightness,
      lightColor: _onSuccessContainerLight,
      darkColor: _onSuccessContainerDark,
    );
  }

  // ==================== WARNING COLORS ====================

  /// Background color for warning containers.
  ///
  /// Use this for backgrounds of warning messages, chips, badges, or cards.
  /// - Light mode: Light orange (pastel)
  /// - Dark mode: Dark orange/brown
  Color get warningContainer {
    return _resolveByBrightness(
      brightness: brightness,
      lightColor: _warningContainerLight,
      darkColor: _warningContainerDark,
    );
  }

  /// Foreground/text color for content on warning containers.
  ///
  /// Use this for text, icons, or other foreground elements on [warningContainer].
  /// Ensures proper contrast and readability.
  /// - Light mode: Very dark brown (almost black)
  /// - Dark mode: Light orange
  Color get onWarningContainer {
    return _resolveByBrightness(
      brightness: brightness,
      lightColor: _onWarningContainerLight,
      darkColor: _onWarningContainerDark,
    );
  }

  // ==================== INFO COLORS ====================

  /// Background color for info containers.
  ///
  /// Use this for backgrounds of informational messages, chips, badges, or cards.
  /// - Light mode: Light blue (pastel)
  /// - Dark mode: Dark blue
  Color get infoContainer {
    return _resolveByBrightness(
      brightness: brightness,
      lightColor: _infoContainerLight,
      darkColor: _infoContainerDark,
    );
  }

  /// Foreground/text color for content on info containers.
  ///
  /// Use this for text, icons, or other foreground elements on [infoContainer].
  /// Ensures proper contrast and readability.
  /// - Light mode: Very dark blue (almost black)
  /// - Dark mode: Light blue
  Color get onInfoContainer {
    return _resolveByBrightness(
      brightness: brightness,
      lightColor: _onInfoContainerLight,
      darkColor: _onInfoContainerDark,
    );
  }
}

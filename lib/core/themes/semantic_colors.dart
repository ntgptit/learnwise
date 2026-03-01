import 'package:flutter/material.dart';

/// Extension on [ColorScheme] to provide semantic colors for success, warning, and info states.
///
/// Material 3 ColorScheme includes built-in support for primary, secondary, and error colors,
/// but doesn't include semantic colors for success, warning, and info states.
/// This extension derives semantic roles from existing Material 3 roles:
/// - success -> tertiary container roles
/// - warning -> secondary container roles
/// - info -> primary container roles
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
///
/// Must follow:
/// - Derive semantic roles from existing Material 3 [ColorScheme] roles.
/// - Keep mappings deterministic and documented.
///
/// Forbidden:
/// - Hardcoding light/dark semantic pairs here when derivation is sufficient.
/// - Using semantic colors directly from feature constants.
extension SemanticColors on ColorScheme {
  Color get successContainer {
    return tertiaryContainer;
  }

  Color get onSuccessContainer {
    return onTertiaryContainer;
  }

  Color get warningContainer {
    return secondaryContainer;
  }

  Color get onWarningContainer {
    return onSecondaryContainer;
  }

  Color get infoContainer {
    return primaryContainer;
  }

  Color get onInfoContainer {
    return onPrimaryContainer;
  }
}

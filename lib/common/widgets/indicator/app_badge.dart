import 'package:flutter/material.dart';

/// Standalone badge for displaying labels or counts.
///
/// This widget uses Material 3's native [Badge] widget for consistent styling
/// and proper semantics. It supports both numeric counts and text labels.
///
/// For numeric values, the badge will use [Badge.count] which handles
/// overflow (e.g., "99+") automatically. For text labels, it uses [Badge]
/// with a label widget.
///
/// Example:
/// ```dart
/// // Numeric badge
/// AppBadge(label: '5')
///
/// // Text badge
/// AppBadge(
///   label: 'New',
///   backgroundColor: colorScheme.errorContainer,
///   foregroundColor: colorScheme.onErrorContainer,
/// )
/// ```
///
/// See also:
///  * [AppBadgeWrapper], for adding overlay badges to widgets (e.g., notification icons)
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.isLarge = false,
  });

  /// The text to display in the badge.
  ///
  /// If this can be parsed as an integer, the badge will use [Badge.count]
  /// which provides special handling for large numbers (e.g., "99+").
  /// Otherwise, it will display as a text label.
  final String label;

  /// Background color of the badge.
  ///
  /// Defaults to [ColorScheme.primary] if not specified.
  final Color? backgroundColor;

  /// Text/foreground color of the badge.
  ///
  /// Defaults to [ColorScheme.onPrimary] if not specified.
  final Color? foregroundColor;

  /// Whether to use a larger size for the badge.
  ///
  /// Defaults to false. When true, uses a size of 20.
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final count = int.tryParse(label);

    if (count != null) {
      // Numeric badge - use Badge.count for automatic "99+" overflow handling
      return Badge.count(
        count: count,
        backgroundColor: backgroundColor,
        textColor: foregroundColor,
        largeSize: isLarge ? 20 : null,
      );
    } else {
      // Label badge - display text as-is
      return Badge(
        label: Text(label),
        backgroundColor: backgroundColor,
        textColor: foregroundColor,
        largeSize: isLarge ? 20 : null,
      );
    }
  }
}

/// Wrapper for adding overlay badges to widgets.
///
/// This widget displays a badge overlaid on top of a child widget,
/// commonly used for notification indicators on icons or avatars.
///
/// The badge can display either a count or a text label. If both are
/// provided, count takes precedence. If neither are provided or count is 0,
/// the child is returned without a badge.
///
/// Example:
/// ```dart
/// // Notification badge with count
/// AppBadgeWrapper(
///   count: 5,
///   child: Icon(Icons.notifications),
/// )
///
/// // Badge with text label
/// AppBadgeWrapper(
///   label: 'New',
///   backgroundColor: colorScheme.errorContainer,
///   child: Icon(Icons.mail),
/// )
///
/// // Badge with custom offset
/// AppBadgeWrapper(
///   count: 3,
///   offset: Offset(4, -4),
///   child: Icon(Icons.shopping_cart),
/// )
/// ```
///
/// See also:
///  * [AppBadge], for standalone badges
class AppBadgeWrapper extends StatelessWidget {
  const AppBadgeWrapper({
    required this.child,
    super.key,
    this.label,
    this.count,
    this.backgroundColor,
    this.foregroundColor,
    this.offset,
  });

  /// The widget to display the badge on top of.
  final Widget child;

  /// Text label to display in the badge.
  ///
  /// Only used if [count] is null or 0. Ignored if [count] is provided.
  final String? label;

  /// Numeric count to display in the badge.
  ///
  /// Takes precedence over [label]. If 0 or null, no badge is shown.
  /// Uses [Badge.count] which handles overflow (e.g., "99+") automatically.
  final int? count;

  /// Background color of the badge.
  ///
  /// Defaults to [ColorScheme.error] if not specified (common for notifications).
  final Color? backgroundColor;

  /// Text/foreground color of the badge.
  ///
  /// Defaults to [ColorScheme.onError] if not specified.
  final Color? foregroundColor;

  /// Optional offset for badge positioning.
  ///
  /// Allows fine-tuning of badge placement relative to the child widget.
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    // Show count badge if count is provided and greater than 0
    if (count != null && count! > 0) {
      return Badge.count(
        count: count!,
        backgroundColor: backgroundColor,
        textColor: foregroundColor,
        offset: offset,
        child: child,
      );
    }

    // Show label badge if label is provided and not empty
    if (label != null && label!.isNotEmpty) {
      return Badge(
        label: Text(label!),
        backgroundColor: backgroundColor,
        textColor: foregroundColor,
        offset: offset,
        child: child,
      );
    }

    // No badge - return child as-is
    return child;
  }
}

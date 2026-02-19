// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../../core/utils/string_utils.dart';

const String _defaultFabSemanticLabel = 'Floating action button';

/// A floating action button following Material Design 3 guidelines.
///
/// This button uses [FloatingActionButton] and supports multiple sizes,
/// icons with optional labels, and proper accessibility. It's designed for
/// the primary action on a screen.
///
/// The FAB is automatically labeled for screen readers. Always provide
/// a [tooltip] or [label] to describe the button's action for users who
/// rely on screen readers.
///
/// Example:
/// ```dart
/// // Simple FAB with icon only
/// LwFab(
///   icon: Icons.add,
///   onPressed: () => handleAdd(),
///   tooltip: 'Add item',
/// )
///
/// // Extended FAB with label
/// LwFab(
///   icon: Icons.edit,
///   label: 'Edit',
///   onPressed: () => handleEdit(),
/// )
///
/// // Small FAB
/// LwFab(
///   icon: Icons.add,
///   size: FabSize.small,
///   onPressed: () => handleAdd(),
/// )
/// ```
///
/// See also:
///  * [LwExpandableFab], for a FAB that expands to show multiple actions
///  * [LwPrimaryButton], for primary actions that aren't floating
class LwFab extends StatelessWidget {
  /// Creates a floating action button.
  ///
  /// The [icon] is required and specifies which icon to display.
  /// The [onPressed] callback is called when the button is tapped.
  const LwFab({
    required this.icon,
    required this.onPressed,
    super.key,
    this.label,
    this.tooltip,
    this.size = FabSize.regular,
    this.heroTag,
  }) : assert(
         label == null || size == FabSize.regular,
         'Extended FAB supports only regular size.',
       );

  /// The icon to display in the FAB.
  final IconData icon;

  /// Called when the FAB is tapped.
  ///
  /// If null, the FAB will be disabled.
  final VoidCallback? onPressed;

  /// Optional text label shown next to the icon.
  ///
  /// When provided, creates an extended FAB with both icon and label.
  /// The label is also used for accessibility if no [tooltip] is provided.
  final String? label;

  /// The tooltip shown on long press and used for accessibility.
  ///
  /// If not provided and [label] is provided, the label will be used.
  /// Should describe the FAB's action (e.g., 'Add item', 'Create note').
  final String? tooltip;

  /// The size of the FAB.
  ///
  /// Defaults to [FabSize.regular].
  final FabSize size;

  /// The tag to apply to the FAB's [Hero] widget.
  ///
  /// Defaults to a tag based on the FAB type. Set to null to disable the
  /// [Hero] effect. This is useful when there are multiple FABs on a screen.
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final String semanticLabel = _resolveSemanticLabel();
    final String? resolvedTooltip = _resolveTooltip();

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: _buildFab(resolvedTooltip: resolvedTooltip),
    );
  }

  Widget _buildFab({required String? resolvedTooltip}) {
    // Extended FAB (with label)
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: resolvedTooltip,
        heroTag: heroTag,
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    // Regular or Small FAB (icon only)
    switch (size) {
      case FabSize.small:
        return FloatingActionButton.small(
          onPressed: onPressed,
          tooltip: resolvedTooltip,
          heroTag: heroTag,
          child: Icon(icon),
        );

      case FabSize.regular:
        return FloatingActionButton(
          onPressed: onPressed,
          tooltip: resolvedTooltip,
          heroTag: heroTag,
          child: Icon(icon),
        );

      case FabSize.large:
        return FloatingActionButton.large(
          onPressed: onPressed,
          tooltip: resolvedTooltip,
          heroTag: heroTag,
          child: Icon(icon),
        );
    }
  }

  String _resolveSemanticLabel() {
    final String? normalizedTooltip = StringUtils.normalizeNullable(tooltip);
    if (normalizedTooltip != null) {
      return normalizedTooltip;
    }
    final String? normalizedLabel = StringUtils.normalizeNullable(label);
    if (normalizedLabel != null) {
      return normalizedLabel;
    }
    return _defaultFabSemanticLabel;
  }

  String? _resolveTooltip() {
    final String? normalizedTooltip = StringUtils.normalizeNullable(tooltip);
    if (normalizedTooltip != null) {
      return normalizedTooltip;
    }
    return StringUtils.normalizeNullable(label);
  }
}

/// Size variants for [LwFab].
enum FabSize {
  /// Small FAB (40x40dp) - Use sparingly for tight spaces.
  small,

  /// Regular FAB (56x56dp) - Default size, recommended for most cases.
  regular,

  /// Large FAB (96x96dp) - Use for prominent primary actions.
  large,
}

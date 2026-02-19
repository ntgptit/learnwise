import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A choice chip for single or multiple selection.
///
/// This chip uses [ChoiceChip] and is designed for selection scenarios
/// where users can choose one or more options from a set. The chip shows
/// a selected state with a checkmark.
///
/// For other chip use cases, see:
/// - [LwAssistChip] for suggesting actions
/// - [LwFilterChip] for filtering content
/// - [LwInputChip] for displaying removable tags
///
/// Example:
/// ```dart
/// LwChip(
///   label: 'Technology',
///   selected: selectedCategory == 'Technology',
///   onTap: () => selectCategory('Technology'),
/// )
/// ```
///
/// See also:
///  * [LwAssistChip], for suggesting actions
///  * [LwFilterChip], for filtering
///  * [LwInputChip], for tags with delete option
class LwChip extends StatelessWidget {
  const LwChip({
    required this.label,
    super.key,
    this.onTap,
    this.selected = false,
  });

  /// The text label shown on the chip.
  final String label;

  /// Called when the chip is tapped.
  ///
  /// If null, the chip cannot be selected/deselected.
  final VoidCallback? onTap;

  /// Whether the chip is currently selected.
  ///
  /// When true, the chip shows a selected state with a checkmark.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!.call(),
    );
  }
}

/// An assist chip for suggesting actions.
///
/// Assist chips help users take action. They're typically displayed
/// in a group and offer quick access to helpful actions or information.
/// Use these for contextual actions like "Add to calendar", "Share", or "Print".
///
/// Unlike [LwChip], assist chips don't have a selected state.
/// They trigger an immediate action when tapped.
///
/// Example:
/// ```dart
/// LwAssistChip(
///   label: 'Add Tag',
///   icon: Icons.add,
///   onTap: () => showAddTagDialog(),
/// )
/// ```
///
/// See also:
///  * [LwChip], for selection chips
///  * [LwFilterChip], for filtering
///  * [LwInputChip], for tags with delete option
class LwAssistChip extends StatelessWidget {
  const LwAssistChip({required this.label, super.key, this.icon, this.onTap});

  /// The text label shown on the chip.
  final String label;

  /// An optional icon displayed before the label.
  ///
  /// Helps users understand the action at a glance.
  final IconData? icon;

  /// Called when the chip is tapped.
  ///
  /// If null, the chip will be disabled.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon != null ? Icon(icon, size: AppSizes.size24) : null,
      label: Text(label),
      onPressed: onTap,
    );
  }
}

/// A filter chip for filtering content.
///
/// Filter chips help users refine content by selecting one or more options
/// from a set of criteria. Unlike [LwChip], filter chips show a checkmark
/// when selected and are designed specifically for filtering scenarios.
///
/// Use filter chips for filtering lists, search results, or any content
/// that can be refined by multiple criteria (e.g., price range, categories,
/// features).
///
/// Example:
/// ```dart
/// LwFilterChip(
///   label: 'Active',
///   selected: filters.showActive,
///   icon: Icons.check_circle,
///   onSelected: (selected) {
///     setState(() => filters.showActive = selected);
///   },
/// )
/// ```
///
/// See also:
///  * [LwChip], for general selection chips
///  * [LwAssistChip], for suggesting actions
///  * [LwInputChip], for tags with delete option
class LwFilterChip extends StatelessWidget {
  const LwFilterChip({
    required this.label,
    required this.selected,
    super.key,
    this.onSelected,
    this.icon,
  });

  /// The text label shown on the chip.
  final String label;

  /// Whether the chip is currently selected.
  ///
  /// When true, the chip shows a selected state with a checkmark.
  final bool selected;

  /// Called when the selection state changes.
  ///
  /// The callback receives the new selected state (true/false).
  /// If null, the chip cannot be selected/deselected.
  final ValueChanged<bool>? onSelected;

  /// An optional icon displayed before the label when not selected.
  ///
  /// The icon is hidden when the chip is selected (replaced by checkmark).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: !selected && icon != null
          ? Icon(icon, size: AppSizes.size24)
          : null,
      showCheckmark: true,
    );
  }
}

/// An input chip for displaying tags with delete option.
///
/// Input chips represent discrete pieces of information entered by the user,
/// such as tags, categories, or attributes. They typically include a delete
/// button to allow users to remove them.
///
/// Use input chips for displaying user-entered data that can be removed,
/// such as email recipients, selected tags, or applied filters.
///
/// Example:
/// ```dart
/// LwInputChip(
///   label: 'Flutter',
///   onDeleted: () => removeTag('Flutter'),
///   onPressed: () => editTag('Flutter'),
///   avatar: CircleAvatar(child: Text('F')),
/// )
/// ```
///
/// See also:
///  * [LwChip], for selection chips
///  * [LwAssistChip], for suggesting actions
///  * [LwFilterChip], for filtering
class LwInputChip extends StatelessWidget {
  const LwInputChip({
    required this.label,
    super.key,
    this.onDeleted,
    this.onPressed,
    this.avatar,
  });

  /// The text label shown on the chip.
  final String label;

  /// Called when the delete button is tapped.
  ///
  /// If null, no delete button is shown.
  final VoidCallback? onDeleted;

  /// Called when the chip itself is tapped.
  ///
  /// If null, the chip is not tappable (but can still be deleted if [onDeleted] is provided).
  final VoidCallback? onPressed;

  /// An optional widget displayed before the label.
  ///
  /// Typically a [CircleAvatar] or [Icon].
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      onPressed: onPressed,
      avatar: avatar,
      deleteIcon: const Icon(Icons.close, size: AppSizes.size24),
    );
  }
}

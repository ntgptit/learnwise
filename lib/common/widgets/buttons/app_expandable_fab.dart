// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';
import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

const double _defaultFabActionDistance = 72.0;
const double _backdropOpacity = AppOpacities.soft35;
const double _labelShadowOpacity = AppOpacities.soft20;
const double _labelShadowBlurRadius = AppSizes.spacing2Xs;
const double _labelShadowOffsetY = AppSizes.size2;
const double _fabActionRightInset = 0.0;
const String _openFabMenuSemanticLabel = 'Open menu';
const String _closeFabMenuSemanticLabel = 'Close menu';

/// A floating action button that expands to show multiple actions.
///
/// This widget creates a FAB that, when tapped, expands to reveal a list of
/// additional action buttons. It's useful when you have multiple related
/// primary actions that you want to make accessible without cluttering the UI.
///
/// The expanded FAB shows a semi-transparent backdrop that can be tapped to
/// close the menu. Each action is displayed with its icon and label.
///
/// Example:
/// ```dart
/// AppExpandableFab(
///   icon: Icons.add,
///   tooltip: 'Create',
///   actions: [
///     FabAction(
///       icon: Icons.note_add,
///       label: 'New Note',
///       onPressed: () => createNote(),
///     ),
///     FabAction(
///       icon: Icons.folder_open,
///       label: 'New Folder',
///       onPressed: () => createFolder(),
///     ),
///     FabAction(
///       icon: Icons.upload_file,
///       label: 'Upload',
///       onPressed: () => uploadFile(),
///     ),
///   ],
/// )
/// ```
///
/// See also:
///  * [AppFab], for a simple single-action FAB
///  * [FabAction], the data class for each expandable action
class AppExpandableFab extends StatefulWidget {
  /// Creates an expandable floating action button.
  ///
  /// The [icon] is displayed on the main FAB.
  /// The [actions] are shown when the FAB is expanded.
  const AppExpandableFab({
    required this.icon,
    required this.actions,
    super.key,
    this.tooltip,
    this.distance = _defaultFabActionDistance,
    this.heroTag,
    this.openIcon,
    this.closeIcon,
    this.collapsedIcon,
    this.expandedIcon,
  }) : assert(
         actions.length > 0,
         'Expandable FAB requires at least one action.',
       );

  /// The icon displayed when the FAB is closed.
  final IconData icon;

  /// The icon displayed when the FAB menu is expanded.
  ///
  /// Prefer [expandedIcon] for new code. This field is kept for backward compatibility.
  final IconData? closeIcon;

  /// An alternative icon for the collapsed FAB state.
  ///
  /// Prefer [collapsedIcon] for new code. This field is kept for backward compatibility.
  final IconData? openIcon;

  /// The icon displayed when the FAB menu is collapsed.
  ///
  /// If not provided, falls back to [openIcon], then [icon].
  final IconData? collapsedIcon;

  /// The icon displayed when the FAB menu is expanded.
  ///
  /// If not provided, falls back to [closeIcon], then [Icons.close].
  final IconData? expandedIcon;

  /// The list of actions to display when expanded.
  final List<FabAction> actions;

  /// The tooltip for the main FAB button.
  final String? tooltip;

  /// The distance between each action button.
  ///
  /// Defaults to 72.0 (standard FAB size + spacing).
  final double distance;

  /// The tag to apply to the FAB's [Hero] widget.
  final Object? heroTag;

  @override
  State<AppExpandableFab> createState() => _AppExpandableFabState();
}

class _AppExpandableFabState extends State<AppExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late final ValueNotifier<bool> _isExpandedNotifier;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.animationFast,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _isExpandedNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _isExpandedNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final bool nextExpanded = !_isExpandedNotifier.value;
    _isExpandedNotifier.value = nextExpanded;
    if (nextExpanded) {
      unawaited(_controller.forward());
      return;
    }
    unawaited(_controller.reverse());
  }

  void _close() {
    if (!_isExpandedNotifier.value) {
      return;
    }
    _toggle();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: _isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: [
            // Backdrop - closes menu when tapped
            if (isExpanded)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _close,
                  child: Container(
                    color: colorScheme.scrim.withValues(
                      alpha: _backdropOpacity,
                    ),
                  ),
                ),
              ),

            // Action buttons
            ..._buildExpandingActionButtons(),

            // Main FAB
            _buildMainFab(isExpanded: isExpanded),
          ],
        );
      },
    );
  }

  Widget _buildMainFab({required bool isExpanded}) {
    final IconData displayIcon = _resolveDisplayIcon(isExpanded: isExpanded);
    final String semanticLabel = isExpanded
        ? _closeFabMenuSemanticLabel
        : (widget.tooltip ?? _openFabMenuSemanticLabel);

    return Semantics(
      label: semanticLabel,
      button: true,
      expanded: isExpanded,
      child: FloatingActionButton(
        heroTag: widget.heroTag,
        onPressed: _toggle,
        tooltip: semanticLabel,
        child: AnimatedSwitcher(
          duration: AppDurations.animationSnappy,
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Icon(displayIcon, key: ValueKey<IconData>(displayIcon)),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final List<Widget> children = <Widget>[];
    final int count = widget.actions.length;

    for (int i = 0; i < count; i++) {
      final FabAction action = widget.actions[i];
      children.add(
        _ExpandingActionButton(
          animation: _expandAnimation,
          index: i,
          distance: widget.distance,
          action: action,
          onPressed: () {
            _close();
            action.onPressed();
          },
        ),
      );
    }

    return children;
  }

  IconData _resolveDisplayIcon({required bool isExpanded}) {
    if (isExpanded) {
      return _resolveExpandedIcon();
    }
    return _resolveCollapsedIcon();
  }

  IconData _resolveCollapsedIcon() {
    if (widget.collapsedIcon != null) {
      return widget.collapsedIcon!;
    }
    if (widget.openIcon != null) {
      return widget.openIcon!;
    }
    return widget.icon;
  }

  IconData _resolveExpandedIcon() {
    if (widget.expandedIcon != null) {
      return widget.expandedIcon!;
    }
    if (widget.closeIcon != null) {
      return widget.closeIcon!;
    }
    return Icons.close;
  }
}

/// An action item for [AppExpandableFab].
///
/// Represents a single action in the expandable FAB menu with an icon,
/// label, and callback.
class FabAction {
  /// Creates a FAB action.
  ///
  /// The [icon], [label], and [onPressed] are required.
  const FabAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The icon for this action.
  final IconData icon;

  /// The label shown next to the action button.
  final String label;

  /// Called when this action is tapped.
  final VoidCallback onPressed;

  /// Optional background color for the action button.
  ///
  /// Defaults to the theme's secondary color.
  final Color? backgroundColor;

  /// Optional foreground/icon color for the action button.
  ///
  /// Defaults to the theme's onSecondary color.
  final Color? foregroundColor;
}

/// Internal widget for each expandable action button.
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.animation,
    required this.index,
    required this.distance,
    required this.action,
    required this.onPressed,
  }) : super(key: null);

  final Animation<double> animation;
  final int index;
  final double distance;
  final FabAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate offset based on index and animation value
        final double offset = distance * (index + 1) * animation.value;

        return Positioned(
          bottom: offset,
          right: _fabActionRightInset,
          child: Opacity(
            opacity: animation.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingSm,
                    vertical: AppSizes.spacing2Xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.shadow.withValues(
                          alpha: _labelShadowOpacity,
                        ),
                        blurRadius: _labelShadowBlurRadius,
                        offset: const Offset(0, _labelShadowOffsetY),
                      ),
                    ],
                  ),
                  child: Text(
                    action.label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingXs),

                // Action button
                Semantics(
                  label: action.label,
                  button: true,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    onPressed: onPressed,
                    backgroundColor:
                        action.backgroundColor ??
                        colorScheme.secondaryContainer,
                    foregroundColor:
                        action.foregroundColor ??
                        colorScheme.onSecondaryContainer,
                    child: Icon(action.icon),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

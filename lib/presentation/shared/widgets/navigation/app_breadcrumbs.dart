import 'dart:async';

import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';
import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

/// Represents a single breadcrumb item in the navigation trail.
///
/// Each item displays a [label] and can be tapped to navigate to that level.
class LwBreadcrumbItem {
  const LwBreadcrumbItem({required this.label});

  /// The display label for this breadcrumb item.
  final String label;
}

/// A horizontal navigation breadcrumb trail for hierarchical navigation.
///
/// Displays a root item followed by a trail of [LwBreadcrumbItem]s,
/// separated by chevron icons. The active (current) item is visually
/// highlighted. Automatically scrolls to show the latest item when the trail
/// expands.
///
/// Common use cases include folder navigation, nested categories, or
/// multi-level settings.
///
/// Example:
/// ```dart
/// LwBreadcrumbs(
///   rootLabel: 'Home',
///   items: [
///     LwBreadcrumbItem(label: 'Documents'),
///     LwBreadcrumbItem(label: 'Projects'),
///     LwBreadcrumbItem(label: '2024'),
///   ],
///   onRootPressed: () => navigateToRoot(),
///   onItemPressed: (index) => navigateToLevel(index),
/// )
/// ```
///
/// See also:
///  * [LwBreadcrumbItem], the item data class
///  * [LwBottomNavBar], for top-level app navigation
class LwBreadcrumbs extends StatefulWidget {
  const LwBreadcrumbs({
    required this.rootLabel,
    required this.items,
    required this.onRootPressed,
    required this.onItemPressed,
    super.key,
  });

  /// The label for the root (home) breadcrumb.
  final String rootLabel;

  /// The list of breadcrumb items to display after the root.
  final List<LwBreadcrumbItem> items;

  /// Called when the user taps the root breadcrumb.
  final VoidCallback onRootPressed;

  /// Called when the user taps a breadcrumb item.
  ///
  /// The [int] parameter is the index of the tapped item in [items].
  final ValueChanged<int> onItemPressed;

  @override
  State<LwBreadcrumbs> createState() => _AppBreadcrumbsState();
}

class _AppBreadcrumbsState extends State<LwBreadcrumbs> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant LwBreadcrumbs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _scrollToEnd();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: _kScrollDuration,
            curve: Curves.easeOutCubic,
          ),
        );
      }
    });
  }

  @override
  // quality-guard: allow-long-function
  // Justification: Declarative UI layout for breadcrumb trail with root + items.
  // Breaking up would obscure the breadcrumb structure and make it harder to understand.
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool hasItems = widget.items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingSm,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_kBreadcrumbContainerRadius),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _BreadcrumbChip(
              icon: Icons.home_rounded,
              label: widget.rootLabel,
              onPressed: widget.onRootPressed,
              isActive: !hasItems,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            for (int i = 0; i < widget.items.length; i++) ...<Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing2Xs,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: _kSeparatorSize,
                  color: colorScheme.onSurfaceVariant.withValues(
                    alpha: AppOpacities.muted55,
                  ),
                ),
              ),
              _BreadcrumbChip(
                icon: Icons.folder_rounded,
                label: widget.items[i].label,
                onPressed: () => widget.onItemPressed(i),
                isActive: i == widget.items.length - 1,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

const Duration _kScrollDuration = AppDurations.animationFast;
const double _kSeparatorSize = 18;
const double _kChipIconSize = 16;
const double _kChipIconGap = 6;
const double _kBreadcrumbContainerRadius = AppSizes.size20;
const double _kBreadcrumbChipRadius = AppSizes.radiusMd;

class _BreadcrumbChip extends StatelessWidget {
  const _BreadcrumbChip({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isActive,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  // quality-guard: allow-long-function
  // Justification: Single Material breadcrumb chip with icon, label, and interactive states.
  // This is a cohesive UI component that should not be fragmented.
  Widget build(BuildContext context) {
    final Color foreground = isActive
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Material(
      color: isActive ? colorScheme.secondaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(_kBreadcrumbChipRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_kBreadcrumbChipRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingSm,
            vertical: AppSizes.spacingXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: _kChipIconSize, color: foreground),
              const SizedBox(width: _kChipIconGap),
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

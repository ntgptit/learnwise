import 'dart:async';

import 'package:flutter/material.dart';

import '../../styles/app_durations.dart';
import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label});

  final String label;
}

class AppBreadcrumbs extends StatefulWidget {
  const AppBreadcrumbs({
    required this.rootLabel,
    required this.items,
    required this.onRootPressed,
    required this.onItemPressed,
    super.key,
  });

  final String rootLabel;
  final List<AppBreadcrumbItem> items;
  final VoidCallback onRootPressed;
  final ValueChanged<int> onItemPressed;

  @override
  State<AppBreadcrumbs> createState() => _AppBreadcrumbsState();
}

class _AppBreadcrumbsState extends State<AppBreadcrumbs> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant AppBreadcrumbs oldWidget) {
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
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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

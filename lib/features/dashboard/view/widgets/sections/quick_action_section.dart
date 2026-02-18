import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../common/styles/app_durations.dart';
import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/styles/app_sizes.dart';
import '../../../model/dashboard_models.dart';

class DashboardQuickActionSection extends StatelessWidget {
  const DashboardQuickActionSection({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DashboardQuickAction? learningAction = _findAction(
      DashboardQuickActionType.learning,
    );
    final DashboardQuickAction? progressAction = _findAction(
      DashboardQuickActionType.progress,
    );
    final DashboardQuickAction? ttsAction = _findAction(
      DashboardQuickActionType.tts,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.dashboardQuickActionsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: DashboardScreenTokens.sectionTitleGap),
        if (learningAction != null)
          _PressScale(
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: _resolveFilledStyle(context: context),
                icon: Icon(_actionIcon(learningAction.type)),
                onPressed: () => _openQuickAction(context, learningAction.type),
                label: Text(_actionLabel(l10n, learningAction.type)),
              ),
            ),
          ),
        const SizedBox(height: DashboardScreenTokens.quickActionSpacing),
        Row(
          children: <Widget>[
            Expanded(
              child: _buildTonalActionButton(
                context: context,
                l10n: l10n,
                action: progressAction,
              ),
            ),
            const SizedBox(width: DashboardScreenTokens.quickActionSpacing),
            Expanded(
              child: _buildOutlinedActionButton(
                context: context,
                l10n: l10n,
                action: ttsAction,
              ),
            ),
          ],
        ),
      ],
    );
  }

  DashboardQuickAction? _findAction(DashboardQuickActionType type) {
    for (final DashboardQuickAction action in snapshot.quickActions) {
      if (action.type == type) {
        return action;
      }
    }
    return null;
  }

  Widget _buildTonalActionButton({
    required BuildContext context,
    required AppLocalizations l10n,
    required DashboardQuickAction? action,
  }) {
    if (action == null) {
      return const SizedBox.shrink();
    }
    return _PressScale(
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          style: _resolveTonalStyle(context: context),
          icon: Icon(_actionIcon(action.type)),
          onPressed: () => _openQuickAction(context, action.type),
          label: Text(_actionLabel(l10n, action.type)),
        ),
      ),
    );
  }

  Widget _buildOutlinedActionButton({
    required BuildContext context,
    required AppLocalizations l10n,
    required DashboardQuickAction? action,
  }) {
    if (action == null) {
      return const SizedBox.shrink();
    }
    return _PressScale(
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: _resolveOutlinedStyle(context: context),
          icon: Icon(_actionIcon(action.type)),
          onPressed: () => _openQuickAction(context, action.type),
          label: Text(_actionLabel(l10n, action.type)),
        ),
      ),
    );
  }
}

ButtonStyle _resolveFilledStyle({required BuildContext context}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    minimumSize: const Size(double.infinity, AppSizes.size56),
    shape: const StadiumBorder(),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.onPrimary.withValues(alpha: AppOpacities.soft12);
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.onPrimary.withValues(alpha: AppOpacities.soft08);
      }
      if (states.contains(WidgetState.focused)) {
        return colorScheme.onPrimary.withValues(alpha: AppOpacities.soft08);
      }
      return null;
    }),
  );
}

ButtonStyle _resolveTonalStyle({required BuildContext context}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  return FilledButton.styleFrom(
    backgroundColor: colorScheme.primaryContainer,
    foregroundColor: colorScheme.onPrimaryContainer,
    minimumSize: const Size(double.infinity, AppSizes.size52),
    shape: const StadiumBorder(),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.onPrimaryContainer.withValues(
          alpha: AppOpacities.soft12,
        );
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.onPrimaryContainer.withValues(
          alpha: AppOpacities.soft08,
        );
      }
      if (states.contains(WidgetState.focused)) {
        return colorScheme.onPrimaryContainer.withValues(
          alpha: AppOpacities.soft08,
        );
      }
      return null;
    }),
  );
}

ButtonStyle _resolveOutlinedStyle({required BuildContext context}) {
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  return OutlinedButton.styleFrom(
    foregroundColor: colorScheme.secondary,
    side: BorderSide(color: colorScheme.secondary),
    minimumSize: const Size(double.infinity, AppSizes.size52),
    shape: const StadiumBorder(),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.secondary.withValues(alpha: AppOpacities.soft12);
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.secondary.withValues(alpha: AppOpacities.soft08);
      }
      if (states.contains(WidgetState.focused)) {
        return colorScheme.secondary.withValues(alpha: AppOpacities.soft08);
      }
      return null;
    }),
  );
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1,
        duration: AppDurations.animationQuick,
        child: widget.child,
      ),
    );
  }
}

String _actionLabel(AppLocalizations l10n, DashboardQuickActionType type) {
  switch (type) {
    case DashboardQuickActionType.learning:
      return l10n.dashboardActionLearning;
    case DashboardQuickActionType.progress:
      return l10n.dashboardActionProgress;
    case DashboardQuickActionType.tts:
      return l10n.dashboardActionTts;
  }
}

IconData _actionIcon(DashboardQuickActionType type) {
  switch (type) {
    case DashboardQuickActionType.learning:
      return Icons.school_outlined;
    case DashboardQuickActionType.progress:
      return Icons.insights_outlined;
    case DashboardQuickActionType.tts:
      return Icons.graphic_eq_outlined;
  }
}

void _openQuickAction(BuildContext context, DashboardQuickActionType type) {
  if (type == DashboardQuickActionType.learning) {
    unawaited(const LearningRoute().push<void>(context));
    return;
  }
  if (type == DashboardQuickActionType.progress) {
    unawaited(const ProgressDetailRoute().push<void>(context));
    return;
  }
  unawaited(const TtsRoute().push<void>(context));
}

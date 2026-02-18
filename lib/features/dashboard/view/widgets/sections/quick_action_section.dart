import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../model/dashboard_models.dart';

class DashboardQuickActionSection extends StatelessWidget {
  const DashboardQuickActionSection({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.dashboardQuickActionsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: DashboardScreenTokens.sectionTitleGap),
        Wrap(
          spacing: DashboardScreenTokens.quickActionSpacing,
          runSpacing: DashboardScreenTokens.quickActionSpacing,
          children: snapshot.quickActions.map((action) {
            return FilledButton.tonalIcon(
              icon: Icon(_actionIcon(action.type)),
              onPressed: () => _openQuickAction(context, action.type),
              label: Text(_actionLabel(l10n, action.type)),
            );
          }).toList(),
        ),
      ],
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

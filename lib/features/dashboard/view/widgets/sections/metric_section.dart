import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/styles/app_sizes.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../model/dashboard_models.dart';

class DashboardMetricSection extends StatelessWidget {
  const DashboardMetricSection({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildTitle(context, l10n),
        const SizedBox(height: DashboardScreenTokens.sectionTitleGap),
        _buildGrid(l10n),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, AppLocalizations l10n) {
    return Text(
      l10n.dashboardOverviewTitle,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildGrid(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final double itemWidth =
            (constraints.maxWidth - DashboardScreenTokens.metricGridSpacing) /
            DashboardScreenTokens.metricColumns;
        return Wrap(
          spacing: DashboardScreenTokens.metricGridSpacing,
          runSpacing: DashboardScreenTokens.metricGridSpacing,
          children: snapshot.metrics.map((metric) {
            return SizedBox(
              width: itemWidth,
              child: AppMetricCard(
                icon: _metricIcon(metric.type),
                label: _metricLabel(l10n, metric.type),
                value: _metricValueText(l10n, metric),
                progress: metric.progress,
                minHeight: DashboardScreenTokens.metricCardMinHeight,
                elevation: AppSizes.size2,
                backgroundColor: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(
                  DashboardScreenTokens.metricCardRadius,
                ),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: AppOpacities.soft20,
                  ),
                ),
                padding: const EdgeInsets.all(
                  DashboardScreenTokens.metricCardPadding,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

String _metricLabel(AppLocalizations l10n, DashboardMetricType type) {
  switch (type) {
    case DashboardMetricType.studyMinutes:
      return l10n.dashboardMetricStudyMinutesLabel;
    case DashboardMetricType.wordsMastered:
      return l10n.dashboardMetricWordsMasteredLabel;
    case DashboardMetricType.weeklyGoal:
      return l10n.dashboardMetricWeeklyGoalLabel;
  }
}

String _metricValueText(AppLocalizations l10n, DashboardMetric metric) {
  switch (metric.type) {
    case DashboardMetricType.studyMinutes:
      return l10n.dashboardMetricMinutesValue(metric.value);
    case DashboardMetricType.wordsMastered:
      return l10n.dashboardMetricWordsValue(metric.value);
    case DashboardMetricType.weeklyGoal:
      return l10n.dashboardMetricGoalValue(metric.value, metric.target);
  }
}

IconData _metricIcon(DashboardMetricType type) {
  switch (type) {
    case DashboardMetricType.studyMinutes:
      return Icons.schedule_rounded;
    case DashboardMetricType.wordsMastered:
      return Icons.auto_stories_outlined;
    case DashboardMetricType.weeklyGoal:
      return Icons.emoji_events_outlined;
  }
}

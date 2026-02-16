import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/route_names.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../model/dashboard_constants.dart';
import '../model/dashboard_models.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<DashboardSnapshot> state = ref.watch(
      dashboardControllerProvider,
    );
    final DashboardController controller = ref.read(
      dashboardControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: SafeArea(
        child: state.when(
          data: (snapshot) {
            return RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                padding: const EdgeInsets.all(
                  DashboardScreenTokens.contentPadding,
                ),
                children: <Widget>[
                  _HeroSection(snapshot: snapshot),
                  const SizedBox(height: DashboardScreenTokens.sectionSpacing),
                  _MetricSection(snapshot: snapshot),
                  const SizedBox(height: DashboardScreenTokens.sectionSpacing),
                  _QuickActionSection(snapshot: snapshot),
                  const SizedBox(height: DashboardScreenTokens.sectionSpacing),
                  _FocusSection(snapshot: snapshot),
                  const SizedBox(height: DashboardScreenTokens.sectionSpacing),
                  _RecentSection(snapshot: snapshot),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return ErrorState(
              title: l10n.dashboardErrorTitle,
              message: l10n.dashboardErrorDescription,
              retryLabel: l10n.dashboardRetryLabel,
              onRetry: controller.refresh,
            );
          },
          loading: () {
            return LoadingState(message: l10n.dashboardLoadingLabel);
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        destinations: <AppBottomNavDestination>[
          AppBottomNavDestination(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: l10n.dashboardNavHome,
          ),
          AppBottomNavDestination(
            icon: Icons.folder_open_outlined,
            selectedIcon: Icons.folder_rounded,
            label: l10n.dashboardNavFolders,
          ),
          AppBottomNavDestination(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.dashboardNavProfile,
          ),
        ],
        selectedIndex: DashboardConstants.dashboardNavIndex,
        onDestinationSelected: (index) {
          if (index == DashboardConstants.dashboardNavIndex) {
            return;
          }
          if (index == DashboardConstants.foldersNavIndex) {
            context.go(RouteNames.folders);
            return;
          }
          if (index == DashboardConstants.profileNavIndex) {
            context.go(RouteNames.profile);
            return;
          }
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = _resolveHeroForegroundColor(colorScheme);

    return Container(
      padding: const EdgeInsets.all(DashboardScreenTokens.headerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          DashboardScreenTokens.headerBorderRadius,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.dashboardGreeting(snapshot.displayName),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DashboardScreenTokens.heroGapSmall),
          Text(
            l10n.dashboardHeroHeadline,
            style: theme.textTheme.titleMedium?.copyWith(
              color: foregroundColor,
            ),
          ),
          const SizedBox(height: DashboardScreenTokens.heroGapLarge),
          Row(
            children: <Widget>[
              _HeroStatChip(
                icon: Icons.local_fire_department_outlined,
                label: l10n.dashboardStreakLabel,
                value: l10n.dashboardStreakValue(snapshot.streakDays),
              ),
              const SizedBox(width: DashboardScreenTokens.heroChipSpacing),
              _HeroStatChip(
                icon: Icons.flag_outlined,
                label: l10n.dashboardGoalProgressLabel,
                value: l10n.dashboardFocusCountLabel(snapshot.focusCardCount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color foregroundColor = _resolveHeroForegroundColor(colorScheme);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(DashboardScreenTokens.heroChipPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(
            alpha: DashboardScreenTokens.softOpacity,
          ),
          borderRadius: BorderRadius.circular(
            DashboardScreenTokens.heroChipRadius,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: foregroundColor),
            const SizedBox(width: DashboardScreenTokens.heroChipSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foregroundColor.withValues(
                        alpha: DashboardScreenTokens.dimOpacity,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricSection extends StatelessWidget {
  const _MetricSection({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.dashboardOverviewTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: DashboardScreenTokens.sectionTitleGap),
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth =
                (constraints.maxWidth -
                    DashboardScreenTokens.metricGridSpacing) /
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
                    padding: const EdgeInsets.all(
                      DashboardScreenTokens.metricCardPadding,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection({required this.snapshot});

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
              onPressed: () => context.push(action.routeName),
              label: Text(_actionLabel(l10n, action.type)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FocusSection extends StatelessWidget {
  const _FocusSection({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: DashboardScreenTokens.focusCardHeight,
      padding: const EdgeInsets.all(DashboardScreenTokens.focusCardPadding),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(
          DashboardScreenTokens.metricCardRadius,
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.track_changes_outlined,
            size: DashboardScreenTokens.focusIconSize,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: DashboardScreenTokens.focusIconGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  l10n.dashboardTodayFocusTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: DashboardScreenTokens.focusTextGap),
                Text(
                  l10n.dashboardFocusCountLabel(snapshot.focusCardCount),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.dashboardRecentTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: DashboardScreenTokens.sectionTitleGap),
        ...snapshot.recentActivities.map((activity) {
          return Container(
            margin: const EdgeInsets.only(
              bottom: DashboardScreenTokens.recentItemGap,
            ),
            padding: const EdgeInsets.all(
              DashboardScreenTokens.recentCardPadding,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                DashboardScreenTokens.recentCardRadius,
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: DashboardScreenTokens.softOpacity,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_recentLabel(l10n, activity.type)),
                const SizedBox(height: DashboardScreenTokens.recentProgressGap),
                LinearProgressIndicator(value: activity.progress),
              ],
            ),
          );
        }),
      ],
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

String _recentLabel(AppLocalizations l10n, DashboardRecentActivityType type) {
  switch (type) {
    case DashboardRecentActivityType.studyCompleted:
      return l10n.dashboardRecentStudyCompleted;
    case DashboardRecentActivityType.progressUpdated:
      return l10n.dashboardRecentProgressUpdated;
    case DashboardRecentActivityType.ttsPracticed:
      return l10n.dashboardRecentTtsPracticed;
  }
}

Color _resolveHeroForegroundColor(ColorScheme colorScheme) {
  if (colorScheme.brightness == Brightness.dark) {
    return colorScheme.onSurface;
  }
  return colorScheme.onPrimary;
}

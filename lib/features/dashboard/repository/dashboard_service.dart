import '../model/dashboard_constants.dart';
import '../model/dashboard_models.dart';
import 'dashboard_repository.dart';

class DashboardService implements DashboardRepository {
  @override
  Future<DashboardSnapshot> loadSnapshot() async {
    return const DashboardSnapshot(
      displayName: DashboardConstants.defaultDisplayName,
      streakDays: DashboardConstants.defaultStreakDays,
      focusCardCount: DashboardConstants.focusCardCount,
      metrics: <DashboardMetric>[
        DashboardMetric(
          type: DashboardMetricType.studyMinutes,
          value: DashboardConstants.studyMinutes,
          target: DashboardConstants.studyMinutesTarget,
          progress: DashboardConstants.studyMinutesProgress,
        ),
        DashboardMetric(
          type: DashboardMetricType.wordsMastered,
          value: DashboardConstants.wordsMastered,
          target: DashboardConstants.wordsMasteredTarget,
          progress: DashboardConstants.wordsMasteredProgress,
        ),
        DashboardMetric(
          type: DashboardMetricType.weeklyGoal,
          value: DashboardConstants.weeklyGoalProgress,
          target: DashboardConstants.weeklyGoalTarget,
          progress: DashboardConstants.weeklyGoalProgressRatio,
        ),
      ],
      quickActions: <DashboardQuickAction>[
        DashboardQuickAction(
          type: DashboardQuickActionType.learning,
          routeName: DashboardRouteMap.learning,
        ),
        DashboardQuickAction(
          type: DashboardQuickActionType.progress,
          routeName: DashboardRouteMap.progress,
        ),
        DashboardQuickAction(
          type: DashboardQuickActionType.tts,
          routeName: DashboardRouteMap.tts,
        ),
      ],
      recentActivities: <DashboardRecentActivity>[
        DashboardRecentActivity(
          type: DashboardRecentActivityType.studyCompleted,
          progress: DashboardConstants.recentStudyCompletedProgress,
        ),
        DashboardRecentActivity(
          type: DashboardRecentActivityType.progressUpdated,
          progress: DashboardConstants.recentProgressUpdatedProgress,
        ),
        DashboardRecentActivity(
          type: DashboardRecentActivityType.ttsPracticed,
          progress: DashboardConstants.recentTtsPracticedProgress,
        ),
      ],
    );
  }
}

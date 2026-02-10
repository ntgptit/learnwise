import '../model/dashboard_const.dart';
import '../model/dashboard_models.dart';
import 'dashboard_repository.dart';

class DashboardService implements DashboardRepository {
  @override
  Future<DashboardSnapshot> loadSnapshot() async {
    return const DashboardSnapshot(
      displayName: DashboardConst.defaultDisplayName,
      streakDays: DashboardConst.defaultStreakDays,
      focusCardCount: DashboardConst.focusCardCount,
      metrics: <DashboardMetric>[
        DashboardMetric(
          type: DashboardMetricType.studyMinutes,
          value: DashboardConst.studyMinutes,
          target: DashboardConst.studyMinutesTarget,
          progress: DashboardConst.studyMinutesProgress,
        ),
        DashboardMetric(
          type: DashboardMetricType.wordsMastered,
          value: DashboardConst.wordsMastered,
          target: DashboardConst.wordsMasteredTarget,
          progress: DashboardConst.wordsMasteredProgress,
        ),
        DashboardMetric(
          type: DashboardMetricType.weeklyGoal,
          value: DashboardConst.weeklyGoalProgress,
          target: DashboardConst.weeklyGoalTarget,
          progress: DashboardConst.weeklyGoalProgressRatio,
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
          progress: DashboardConst.recentStudyCompletedProgress,
        ),
        DashboardRecentActivity(
          type: DashboardRecentActivityType.progressUpdated,
          progress: DashboardConst.recentProgressUpdatedProgress,
        ),
        DashboardRecentActivity(
          type: DashboardRecentActivityType.ttsPracticed,
          progress: DashboardConst.recentTtsPracticedProgress,
        ),
      ],
    );
  }
}

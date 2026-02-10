import '../../../app/router/route_names.dart';

enum DashboardMetricType { studyMinutes, wordsMastered, weeklyGoal }

enum DashboardQuickActionType { learning, progress, tts }

enum DashboardRecentActivityType {
  studyCompleted,
  progressUpdated,
  ttsPracticed,
}

class DashboardMetric {
  const DashboardMetric({
    required this.type,
    required this.value,
    required this.target,
    required this.progress,
  });

  final DashboardMetricType type;
  final int value;
  final int target;
  final double progress;
}

class DashboardQuickAction {
  const DashboardQuickAction({required this.type, required this.routeName});

  final DashboardQuickActionType type;
  final String routeName;
}

class DashboardRecentActivity {
  const DashboardRecentActivity({required this.type, required this.progress});

  final DashboardRecentActivityType type;
  final double progress;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.displayName,
    required this.streakDays,
    required this.focusCardCount,
    required this.metrics,
    required this.quickActions,
    required this.recentActivities,
  });

  final String displayName;
  final int streakDays;
  final int focusCardCount;
  final List<DashboardMetric> metrics;
  final List<DashboardQuickAction> quickActions;
  final List<DashboardRecentActivity> recentActivities;
}

class DashboardRouteMap {
  const DashboardRouteMap._();

  static const String learning = RouteNames.learning;
  static const String progress = RouteNames.progressDetail;
  static const String tts = RouteNames.tts;
}

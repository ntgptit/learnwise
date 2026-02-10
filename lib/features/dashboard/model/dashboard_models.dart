import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/router/route_names.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

enum DashboardMetricType { studyMinutes, wordsMastered, weeklyGoal }

enum DashboardQuickActionType { learning, progress, tts }

enum DashboardRecentActivityType {
  studyCompleted,
  progressUpdated,
  ttsPracticed,
}

@freezed
sealed class DashboardMetric with _$DashboardMetric {
  @JsonSerializable(explicitToJson: true)
  const factory DashboardMetric({
    required DashboardMetricType type,
    required int value,
    required int target,
    required double progress,
  }) = _DashboardMetric;

  factory DashboardMetric.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricFromJson(json);
}

@freezed
sealed class DashboardQuickAction with _$DashboardQuickAction {
  @JsonSerializable(explicitToJson: true)
  const factory DashboardQuickAction({
    required DashboardQuickActionType type,
    required String routeName,
  }) = _DashboardQuickAction;

  factory DashboardQuickAction.fromJson(Map<String, dynamic> json) =>
      _$DashboardQuickActionFromJson(json);
}

@freezed
sealed class DashboardRecentActivity with _$DashboardRecentActivity {
  @JsonSerializable(explicitToJson: true)
  const factory DashboardRecentActivity({
    required DashboardRecentActivityType type,
    required double progress,
  }) = _DashboardRecentActivity;

  factory DashboardRecentActivity.fromJson(Map<String, dynamic> json) =>
      _$DashboardRecentActivityFromJson(json);
}

@freezed
sealed class DashboardSnapshot with _$DashboardSnapshot {
  @JsonSerializable(explicitToJson: true)
  const factory DashboardSnapshot({
    required String displayName,
    required int streakDays,
    required int focusCardCount,
    required List<DashboardMetric> metrics,
    required List<DashboardQuickAction> quickActions,
    required List<DashboardRecentActivity> recentActivities,
  }) = _DashboardSnapshot;

  factory DashboardSnapshot.fromJson(Map<String, dynamic> json) =>
      _$DashboardSnapshotFromJson(json);
}

class DashboardRouteMap {
  const DashboardRouteMap._();

  static const String learning = RouteNames.learning;
  static const String progress = RouteNames.progressDetail;
  static const String tts = RouteNames.tts;
}

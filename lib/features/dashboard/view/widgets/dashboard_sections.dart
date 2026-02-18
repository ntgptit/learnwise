import 'package:flutter/material.dart';

import '../../model/dashboard_models.dart';
import 'sections/focus_section.dart';
import 'sections/hero_section.dart';
import 'sections/metric_section.dart';
import 'sections/quick_action_section.dart';
import 'sections/recent_section.dart';
import 'sections/section_gap.dart';

List<Widget> buildDashboardSectionItems({
  required BuildContext context,
  required DashboardSnapshot snapshot,
}) {
  return <Widget>[
    DashboardHeroSection(snapshot: snapshot),
    const DashboardSectionGap(),
    DashboardQuickActionSection(snapshot: snapshot),
    const DashboardSectionGap(),
    DashboardMetricSection(snapshot: snapshot),
    const DashboardSectionGap(),
    DashboardFocusSection(snapshot: snapshot),
    const DashboardSectionGap(),
    DashboardRecentSection(snapshot: snapshot),
  ];
}

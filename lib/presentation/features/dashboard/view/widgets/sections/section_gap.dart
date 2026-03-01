import 'package:flutter/widgets.dart';

import 'package:learnwise/presentation/shared/styles/app_screen_tokens.dart';

class DashboardSectionGap extends StatelessWidget {
  const DashboardSectionGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: DashboardScreenTokens.sectionSpacing);
  }
}

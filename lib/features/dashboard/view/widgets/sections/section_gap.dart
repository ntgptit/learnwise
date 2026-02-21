import 'package:flutter/widgets.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';

class DashboardSectionGap extends StatelessWidget {
  const DashboardSectionGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const LwSpacedColumn(
      spacing: DashboardScreenTokens.sectionSpacing,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[SizedBox.shrink(), SizedBox.shrink()],
    );
  }
}

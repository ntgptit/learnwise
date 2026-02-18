import 'package:flutter/material.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';

class FlashcardStudyAction {
  const FlashcardStudyAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class FlashcardStudyActionSection extends StatelessWidget {
  const FlashcardStudyActionSection({required this.actions, super.key});

  final List<FlashcardStudyAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = <Widget>[];
    for (int index = 0; index < actions.length; index++) {
      final FlashcardStudyAction action = actions[index];
      children.add(
        AppActionTile(
          label: action.label,
          icon: action.icon,
          onPressed: action.onPressed,
        ),
      );
      if (index == actions.length - 1) {
        continue;
      }
      children.add(
        const SizedBox(height: FlashcardScreenTokens.actionTileSpacing),
      );
    }
    return Column(children: children);
  }
}

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

    return Column(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: FlashcardScreenTokens.actionTileSpacing,
          ),
          child: AppActionTile(
            label: action.label,
            icon: action.icon,
            onPressed: action.onPressed,
          ),
        );
      }).toList(),
    );
  }
}

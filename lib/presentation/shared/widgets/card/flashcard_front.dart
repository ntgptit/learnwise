import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import 'app_card.dart';

class LwFlashcardFront extends StatelessWidget {
  const LwFlashcardFront({
    required this.word,
    super.key,
    this.pronunciation,
    this.trailing,
  });

  final String word;
  final String? pronunciation;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Widget trailingWidget = trailing ?? const SizedBox.shrink();

    return LwCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[trailingWidget],
          ),
          Text(word, style: textTheme.headlineSmall),
          if (pronunciation != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacingXs),
            Text(pronunciation!, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import 'app_card.dart';

class FlashcardFront extends StatelessWidget {
  const FlashcardFront({
    required this.word, super.key,
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

    return AppCard(
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

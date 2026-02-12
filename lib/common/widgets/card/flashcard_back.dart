import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import 'app_card.dart';

class FlashcardBack extends StatelessWidget {
  const FlashcardBack({required this.meaning, super.key, this.example});

  final String meaning;
  final String? example;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Meaning', style: textTheme.labelLarge),
          const SizedBox(height: AppSizes.spacingXs),
          Text(meaning, style: textTheme.bodyLarge),
          if (example != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacingSm),
            Text('Example', style: textTheme.labelLarge),
            const SizedBox(height: AppSizes.spacingXs),
            Text(example!, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

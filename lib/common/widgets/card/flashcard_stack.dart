import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class FlashcardStack extends StatelessWidget {
  const FlashcardStack({
    super.key,
    required this.cards,
    this.maxVisible = 3,
    this.stackOffset = AppSizes.spacingXs,
  });

  final List<Widget> cards;
  final int maxVisible;
  final double stackOffset;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final int visibleCount = cards.length < maxVisible
        ? cards.length
        : maxVisible;
    final List<Widget> layers = <Widget>[];

    for (int index = visibleCount - 1; index >= 0; index--) {
      layers.add(
        Positioned.fill(
          top: index * stackOffset,
          left: index * stackOffset,
          right: index * stackOffset,
          child: cards[index],
        ),
      );
    }

    return SizedBox(
      height: AppSizes.size240,
      child: Stack(children: layers),
    );
  }
}

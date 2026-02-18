import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/app/theme/semantic_colors.dart';

void main() {
  group('SemanticColors', () {
    test(
      'derives semantic colors from M3 container roles for light scheme',
      () {
        const ColorScheme colorScheme = ColorScheme.light();

        expect(colorScheme.successContainer, colorScheme.tertiaryContainer);
        expect(colorScheme.onSuccessContainer, colorScheme.onTertiaryContainer);
        expect(colorScheme.warningContainer, colorScheme.secondaryContainer);
        expect(
          colorScheme.onWarningContainer,
          colorScheme.onSecondaryContainer,
        );
        expect(colorScheme.infoContainer, colorScheme.primaryContainer);
        expect(colorScheme.onInfoContainer, colorScheme.onPrimaryContainer);
      },
    );

    test('derives semantic colors from M3 container roles for dark scheme', () {
      const ColorScheme colorScheme = ColorScheme.dark();

      expect(colorScheme.successContainer, colorScheme.tertiaryContainer);
      expect(colorScheme.onSuccessContainer, colorScheme.onTertiaryContainer);
      expect(colorScheme.warningContainer, colorScheme.secondaryContainer);
      expect(colorScheme.onWarningContainer, colorScheme.onSecondaryContainer);
      expect(colorScheme.infoContainer, colorScheme.primaryContainer);
      expect(colorScheme.onInfoContainer, colorScheme.onPrimaryContainer);
    });
  });
}

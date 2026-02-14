import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/app/theme/semantic_colors.dart';

void main() {
  group('SemanticColors', () {
    test('returns expected light semantic colors', () {
      const ColorScheme colorScheme = ColorScheme.light();

      expect(colorScheme.successContainer, const Color(0xFFD1F4E0));
      expect(colorScheme.onSuccessContainer, const Color(0xFF002111));
      expect(colorScheme.warningContainer, const Color(0xFFFFE0B2));
      expect(colorScheme.onWarningContainer, const Color(0xFF2E1500));
      expect(colorScheme.infoContainer, const Color(0xFFD0E4FF));
      expect(colorScheme.onInfoContainer, const Color(0xFF001D35));
    });

    test('returns expected dark semantic colors', () {
      const ColorScheme colorScheme = ColorScheme.dark();

      expect(colorScheme.successContainer, const Color(0xFF0D5028));
      expect(colorScheme.onSuccessContainer, const Color(0xFFB3ECC8));
      expect(colorScheme.warningContainer, const Color(0xFF5C3800));
      expect(colorScheme.onWarningContainer, const Color(0xFFFFDCC1));
      expect(colorScheme.infoContainer, const Color(0xFF004A77));
      expect(colorScheme.onInfoContainer, const Color(0xFFADCAFA));
    });
  });
}

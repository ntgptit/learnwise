import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/utils/string_utils.dart';

void main() {
  group('StringUtils.normalize', () {
    test('trims leading and trailing spaces', () {
      expect(StringUtils.normalize('  hello  '), 'hello');
    });
  });

  group('StringUtils.normalizeNullable', () {
    test('returns null when value is null', () {
      expect(StringUtils.normalizeNullable(null), isNull);
    });

    test('returns null when value is blank', () {
      expect(StringUtils.normalizeNullable('   '), isNull);
    });

    test('returns trimmed text when value has content', () {
      expect(StringUtils.normalizeNullable('  hello  '), 'hello');
    });
  });

  group('StringUtils blank checks', () {
    test('isBlank is true for null and blank values', () {
      expect(StringUtils.isBlank(null), isTrue);
      expect(StringUtils.isBlank('   '), isTrue);
    });

    test('isNotBlank is true for non-blank values', () {
      expect(StringUtils.isNotBlank('  hello  '), isTrue);
    });
  });

  group('NullableStringUtilsX', () {
    test('normalizedOrNull works for nullable string', () {
      const String value = '  hello  ';
      expect((value as String?).normalizedOrNull, 'hello');
    });

    test('isBlank works for nullable string', () {
      const String value = '   ';
      expect((value as String?).isBlank, isTrue);
      expect((value as String?).isNotBlank, isFalse);
    });
  });

  group('StringUtilsX', () {
    test('normalized trims non-null string', () {
      const String value = '  hello  ';
      expect(value.normalized, 'hello');
    });
  });
}

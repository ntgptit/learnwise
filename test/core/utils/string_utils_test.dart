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

  group('StringUtils empty checks', () {
    test('isEmpty and isNotEmpty follow null-safe behavior', () {
      expect(StringUtils.isEmpty(null), isTrue);
      expect(StringUtils.isEmpty(''), isTrue);
      expect(StringUtils.isEmpty('x'), isFalse);
      expect(StringUtils.isNotEmpty('x'), isTrue);
    });
  });

  group('StringUtils comparisons', () {
    test('startsWithIgnoreCase handles null-safe comparison', () {
      expect(
        StringUtils.startsWithIgnoreCase(value: 'Prefix', prefix: 'pre'),
        isTrue,
      );
      expect(
        StringUtils.startsWithIgnoreCase(value: null, prefix: 'pre'),
        isFalse,
      );
    });
  });

  group('StringUtils slicing helpers', () {
    test('slice handles positive and negative boundaries', () {
      expect(StringUtils.slice('abcdef', start: 1, end: 4), 'bcd');
      expect(StringUtils.slice('abcdef', start: -2), 'ef');
      expect(StringUtils.slice('abcdef', start: 4, end: 2), isEmpty);
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

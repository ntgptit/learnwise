class StringUtils {
  const StringUtils._();

  static const String empty = '';

  static bool isEmpty(String? value) {
    if (value == null) {
      return true;
    }
    return value.isEmpty;
  }

  static bool isNotEmpty(String? value) {
    return !isEmpty(value);
  }

  static String normalize(String value) {
    return value.trim();
  }

  static String? normalizeNullable(String? value) {
    if (value == null) {
      return null;
    }
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static bool isBlank(String? value) {
    return normalizeNullable(value) == null;
  }

  static bool isNotBlank(String? value) {
    return !isBlank(value);
  }

  static String toLower(String value) {
    return value.toLowerCase();
  }

  static String toUpper(String value) {
    return value.toUpperCase();
  }

  static String normalizeLower(String value) {
    return toLower(normalize(value));
  }

  static String normalizeUpper(String value) {
    return toUpper(normalize(value));
  }

  static bool startsWithIgnoreCase({
    required String? value,
    required String? prefix,
  }) {
    if (value == null || prefix == null) {
      return false;
    }
    return toLower(value).startsWith(toLower(prefix));
  }

  static String slice(String value, {required int start, int? end}) {
    final int length = value.length;
    int resolvedStart = _resolveIndex(index: start, length: length);
    int resolvedEnd = _resolveIndex(index: end ?? length, length: length);

    resolvedStart = _clampIndex(resolvedStart, length);
    resolvedEnd = _clampIndex(resolvedEnd, length);

    if (resolvedEnd < resolvedStart) {
      return empty;
    }

    return value.substring(resolvedStart, resolvedEnd);
  }

  static int _resolveIndex({required int index, required int length}) {
    if (index >= 0) {
      return index;
    }
    return length + index;
  }

  static int _clampIndex(int index, int maxLength) {
    if (index < 0) {
      return 0;
    }
    if (index > maxLength) {
      return maxLength;
    }
    return index;
  }
}

extension NullableStringUtilsX on String? {
  String? get normalizedOrNull {
    return StringUtils.normalizeNullable(this);
  }

  bool get isBlank {
    return StringUtils.isBlank(this);
  }

  bool get isNotBlank {
    return StringUtils.isNotBlank(this);
  }
}

extension StringUtilsX on String {
  String get normalized {
    return StringUtils.normalize(this);
  }
}

class StringUtils {
  const StringUtils._();

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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/local/prefs_storage.dart';
import '../../core/utils/string_utils.dart';

part 'app_theme_mode_controller.g.dart';

class AppThemeModeCode {
  const AppThemeModeCode._();

  static const String system = 'SYSTEM';
  static const String light = 'LIGHT';
  static const String dark = 'DARK';
}

@Riverpod(keepAlive: true)
class AppThemeModeController extends _$AppThemeModeController {
  late final PrefsStorage _prefsStorage;

  @override
  ThemeMode build() {
    _prefsStorage = ref.read(prefsStorageProvider);
    unawaited(_hydrateFromStorage());
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state == themeMode) {
      return;
    }
    state = themeMode;
    await _prefsStorage.saveThemeModeCode(_encodeThemeMode(themeMode));
  }

  Future<void> resetThemeMode() async {
    state = ThemeMode.system;
    await _prefsStorage.clearThemeModeCode();
  }

  Future<void> _hydrateFromStorage() async {
    final String? rawThemeMode = await _prefsStorage.readThemeModeCode();
    final ThemeMode resolvedThemeMode = _decodeThemeMode(rawThemeMode);
    if (!ref.mounted) {
      return;
    }
    state = resolvedThemeMode;
  }

  ThemeMode _decodeThemeMode(String? rawValue) {
    final String? normalizedValue = StringUtils.normalizeNullable(rawValue);
    if (normalizedValue == null) {
      return ThemeMode.system;
    }
    final String uppercasedValue = normalizedValue.toUpperCase();
    if (uppercasedValue == AppThemeModeCode.light) {
      return ThemeMode.light;
    }
    if (uppercasedValue == AppThemeModeCode.dark) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  String _encodeThemeMode(ThemeMode themeMode) {
    if (themeMode == ThemeMode.light) {
      return AppThemeModeCode.light;
    }
    if (themeMode == ThemeMode.dark) {
      return AppThemeModeCode.dark;
    }
    return AppThemeModeCode.system;
  }
}

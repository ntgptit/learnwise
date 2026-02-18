import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/local/prefs_storage.dart';

part 'app_theme_mode_controller.g.dart';

/// Stable persisted codes for [ThemeMode].
enum AppThemeModeCode { system, light, dark }

/// Theme mode state controller.
///
/// Must follow:
/// - Persist user-selected [ThemeMode] through [PrefsStorage].
/// - Keep encode/decode centralized and backward-compatible.
/// - Use Riverpod lifecycle safety (`ref.mounted`) for async hydration.
///
/// Forbidden:
/// - UI-layer direct persistence access for theme mode.
/// - Scattered encode/decode logic in widgets.
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
    if (rawValue == null) {
      return ThemeMode.system;
    }

    final AppThemeModeCode? legacyCode = _decodeLegacyThemeModeCode(rawValue);
    if (legacyCode != null) {
      return _toThemeMode(legacyCode);
    }

    final AppThemeModeCode code = AppThemeModeCode.values.firstWhere(
      (value) => value.name == rawValue,
      orElse: () => AppThemeModeCode.system,
    );
    return _toThemeMode(code);
  }

  AppThemeModeCode? _decodeLegacyThemeModeCode(String rawValue) {
    if (rawValue == 'SYSTEM') {
      return AppThemeModeCode.system;
    }
    if (rawValue == 'LIGHT') {
      return AppThemeModeCode.light;
    }
    if (rawValue == 'DARK') {
      return AppThemeModeCode.dark;
    }
    return null;
  }

  String _encodeThemeMode(ThemeMode themeMode) {
    return _toThemeModeCode(themeMode).name;
  }

  ThemeMode _toThemeMode(AppThemeModeCode code) {
    if (code == AppThemeModeCode.light) {
      return ThemeMode.light;
    }
    if (code == AppThemeModeCode.dark) {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  AppThemeModeCode _toThemeModeCode(ThemeMode themeMode) {
    if (themeMode == ThemeMode.light) {
      return AppThemeModeCode.light;
    }
    if (themeMode == ThemeMode.dark) {
      return AppThemeModeCode.dark;
    }
    return AppThemeModeCode.system;
  }
}

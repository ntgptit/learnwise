import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/string_utils.dart';

part 'prefs_storage.g.dart';

class PrefsStorageKey {
  const PrefsStorageKey._();

  static const String localeCode = 'learnwise.prefs.locale_code';
  static const String darkModeEnabled = 'learnwise.prefs.dark_mode';
}

typedef SharedPreferencesLoader = Future<SharedPreferences> Function();

abstract class PrefsStorage {
  Future<void> saveLocaleCode(String localeCode);

  Future<String?> readLocaleCode();

  Future<void> clearLocaleCode();

  Future<void> saveDarkModeEnabled({required bool enabled});

  Future<bool?> readDarkModeEnabled();

  Future<void> clearDarkModeEnabled();
}

@Riverpod(keepAlive: true)
PrefsStorage prefsStorage(Ref ref) {
  return SharedPrefsStorage(instanceLoader: SharedPreferences.getInstance);
}

class SharedPrefsStorage implements PrefsStorage {
  SharedPrefsStorage({required SharedPreferencesLoader instanceLoader})
    : _prefsFuture = instanceLoader();

  final Future<SharedPreferences> _prefsFuture;

  @override
  Future<void> saveLocaleCode(String localeCode) async {
    final String value = StringUtils.normalize(localeCode);
    if (value.isEmpty) {
      throw ArgumentError.value(
        localeCode,
        'localeCode',
        'Locale code must not be empty.',
      );
    }

    final SharedPreferences prefs = await _prefs();
    await prefs.setString(PrefsStorageKey.localeCode, value);
  }

  @override
  Future<String?> readLocaleCode() async {
    final SharedPreferences prefs = await _prefs();
    return prefs.getString(PrefsStorageKey.localeCode);
  }

  @override
  Future<void> clearLocaleCode() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(PrefsStorageKey.localeCode);
  }

  @override
  Future<void> saveDarkModeEnabled({required bool enabled}) async {
    final SharedPreferences prefs = await _prefs();
    await prefs.setBool(PrefsStorageKey.darkModeEnabled, enabled);
  }

  @override
  Future<bool?> readDarkModeEnabled() async {
    final SharedPreferences prefs = await _prefs();
    return prefs.getBool(PrefsStorageKey.darkModeEnabled);
  }

  @override
  Future<void> clearDarkModeEnabled() async {
    final SharedPreferences prefs = await _prefs();
    await prefs.remove(PrefsStorageKey.darkModeEnabled);
  }

  Future<SharedPreferences> _prefs() async {
    return _prefsFuture;
  }
}

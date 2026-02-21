part of 'profile_tts_voice_settings_section.dart';

extension _ProfileTtsVoiceSettingsSectionTextExtension
    on ProfileTtsVoiceSettingsSection {
  void _showVoiceTestValidationError({
    required BuildContext context,
    required String message,
  }) {
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
      context,
    );
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _resolvePreviewText({
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<_TtsDraft> draftNotifier,
    required ValueNotifier<bool> useDefaultTestTextNotifier,
    required TextEditingController testTextController,
  }) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (useDefaultTestTextNotifier.value) {
      final TtsState ttsState = ref.read(ttsControllerProvider);
      final _TtsDraft draft = draftNotifier.value;
      final String defaultText = _resolveDefaultTestText(
        context: context,
        draft: draft,
        voices: ttsState.engine.voices,
        l10n: l10n,
      );
      return StringUtils.normalize(defaultText);
    }
    return StringUtils.normalize(testTextController.text);
  }

  String _resolveDefaultTestText({
    required BuildContext context,
    required _TtsDraft draft,
    required List<TtsVoiceOption> voices,
    required AppLocalizations l10n,
  }) {
    final String languageCode = _resolvePreferredLanguageCode(
      context: context,
      voiceId: draft.voiceId,
      voices: voices,
    );
    if (languageCode == _LanguageCode.vi) {
      return l10n.profileVoiceTestDefaultTextVi;
    }
    if (languageCode == _LanguageCode.ko) {
      return l10n.profileVoiceTestDefaultTextKo;
    }
    if (languageCode == _LanguageCode.ja) {
      return l10n.profileVoiceTestDefaultTextJa;
    }
    return l10n.profileVoiceTestDefaultTextEn;
  }

  String _resolvePreferredLanguageCode({
    required BuildContext context,
    required String? voiceId,
    required List<TtsVoiceOption> voices,
  }) {
    final String? normalizedVoiceId = StringUtils.normalizeNullable(voiceId);
    if (normalizedVoiceId != null) {
      for (final TtsVoiceOption voice in voices) {
        if (voice.id != normalizedVoiceId) {
          continue;
        }
        final String voiceLanguageCode = _extractLanguageCode(voice.locale);
        if (_isSupportedLanguageCode(voiceLanguageCode)) {
          return voiceLanguageCode;
        }
        break;
      }
    }
    return _resolveAppLocaleLanguageCode(context: context);
  }

  String _resolveAppLocaleLanguageCode({required BuildContext context}) {
    final String localeLanguageCode = Localizations.localeOf(
      context,
    ).languageCode;
    final String normalizedLanguageCode = StringUtils.toLower(
      localeLanguageCode,
    );
    if (_isSupportedLanguageCode(normalizedLanguageCode)) {
      return normalizedLanguageCode;
    }
    return _LanguageCode.en;
  }

  String _extractLanguageCode(String locale) {
    final String normalizedLocale = StringUtils.toLower(
      StringUtils.normalize(locale),
    );
    if (normalizedLocale.isEmpty) {
      return '';
    }
    final int separatorIndex = normalizedLocale.indexOf(RegExp('[-_]'));
    if (separatorIndex < 0) {
      return normalizedLocale;
    }
    return StringUtils.slice(normalizedLocale, start: 0, end: separatorIndex);
  }

  bool _isSupportedLanguageCode(String languageCode) {
    return languageCode == _LanguageCode.en ||
        languageCode == _LanguageCode.vi ||
        languageCode == _LanguageCode.ko ||
        languageCode == _LanguageCode.ja;
  }

  Future<void> _saveGlobalVoiceSettings({
    required WidgetRef ref,
    required UserStudySettings baseSettings,
    required ValueNotifier<_TtsDraft> draftNotifier,
  }) async {
    await ref.read(ttsControllerProvider.notifier).stopReading();
    final _TtsDraft draft = draftNotifier.value;
    final UserStudySettings nextSettings = baseSettings.copyWith(
      ttsVoiceId: draft.voiceId,
      clearTtsVoiceId: draft.voiceId == null,
      ttsSpeechRate: draft.speechRate,
      ttsPitch: draft.pitch,
      ttsVolume: draft.volume,
    );
    await ref
        .read(profileControllerProvider.notifier)
        .updateSettings(nextSettings);
  }
}

part of 'profile_tts_voice_settings_section.dart';

extension _ProfileTtsVoiceSettingsSectionRuntimeExtension
    on ProfileTtsVoiceSettingsSection {
  bool _isVoiceInputDisabled(TtsEngineState engine) {
    return engine.status.isLoadingVoices || engine.status.isInitializing;
  }

  VoidCallback? _resolveRefreshHandler({
    required WidgetRef ref,
    required TtsEngineState engine,
  }) {
    if (engine.status.isLoadingVoices) {
      return null;
    }
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    return () {
      unawaited(
        controller.loadVoices(localePrefix: TtsConstants.koreanLocalePrefix),
      );
    };
  }

  List<LwSelectOption<int?>> _buildVoiceItems({
    required AppLocalizations l10n,
    required List<TtsVoiceOption> voices,
  }) {
    return <LwSelectOption<int?>>[
      LwSelectOption<int?>(value: null, label: l10n.systemDefaultVoice),
      ...voices.asMap().entries.map((entry) {
        final int index = entry.key + 1;
        final TtsVoiceOption voice = entry.value;
        final String alias = l10n.koreanVoiceAlias(
          index.toString().padLeft(
            TtsConstants.voiceAliasPadWidth,
            TtsConstants.voiceAliasPadChar,
          ),
        );
        return LwSelectOption<int?>(
          value: entry.key,
          label: '$alias - ${voice.displayLabel}',
        );
      }),
    ];
  }

  List<TtsVoiceOption> _resolveUniqueVoices(List<TtsVoiceOption> voices) {
    final Set<String> seenIds = <String>{};
    final List<TtsVoiceOption> uniqueVoices = <TtsVoiceOption>[];
    for (final TtsVoiceOption voice in voices) {
      final String normalizedVoiceId = StringUtils.normalize(voice.id);
      if (normalizedVoiceId.isEmpty) {
        continue;
      }
      final String dedupeId = StringUtils.toLower(normalizedVoiceId);
      if (seenIds.contains(dedupeId)) {
        continue;
      }
      seenIds.add(dedupeId);
      uniqueVoices.add(voice);
    }
    return uniqueVoices;
  }

  List<TtsVoiceOption> _resolveKoreanVoices(List<TtsVoiceOption> voices) {
    final List<TtsVoiceOption> koreanVoices = <TtsVoiceOption>[];
    for (final TtsVoiceOption voice in voices) {
      if (!StringUtils.startsWithIgnoreCase(
        value: voice.locale,
        prefix: TtsConstants.koreanLocalePrefix,
      )) {
        continue;
      }
      koreanVoices.add(voice);
    }
    return koreanVoices;
  }

  int? _resolveDropdownVoiceIndex({
    required String? draftVoiceId,
    required List<TtsVoiceOption> voices,
  }) {
    final String? normalizedDraftVoiceId = StringUtils.normalizeNullable(
      draftVoiceId,
    );
    if (normalizedDraftVoiceId == null) {
      return null;
    }
    final String normalizedDraftKey = StringUtils.toLower(
      normalizedDraftVoiceId,
    );
    for (int index = 0; index < voices.length; index += 1) {
      final TtsVoiceOption voice = voices[index];
      final String voiceKey = StringUtils.toLower(
        StringUtils.normalize(voice.id),
      );
      if (voiceKey != normalizedDraftKey) {
        continue;
      }
      return index;
    }
    return null;
  }

  String? _resolveVoiceIdByDropdownIndex({
    required int? voiceIndex,
    required List<TtsVoiceOption> voices,
  }) {
    if (voiceIndex == null) {
      return null;
    }
    if (voiceIndex < 0 || voiceIndex >= voices.length) {
      return null;
    }
    return voices[voiceIndex].id;
  }

  Future<void> _bootstrapVoices({required WidgetRef ref}) async {
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    final TtsState state = ref.read(ttsControllerProvider);
    if (state.engine.isInitialized && _hasKoreanVoice(state.engine.voices)) {
      return;
    }
    await controller.initialize();
    final TtsState initializedState = ref.read(ttsControllerProvider);
    if (_hasKoreanVoice(initializedState.engine.voices)) {
      return;
    }
    await controller.loadVoices(localePrefix: TtsConstants.koreanLocalePrefix);
  }

  bool _hasKoreanVoice(List<TtsVoiceOption> voices) {
    for (final TtsVoiceOption voice in voices) {
      if (!StringUtils.startsWithIgnoreCase(
        value: voice.locale,
        prefix: TtsConstants.koreanLocalePrefix,
      )) {
        continue;
      }
      return true;
    }
    return false;
  }

  void _bindDraft({
    required WidgetRef ref,
    required UserProfile profile,
    required ValueNotifier<_TtsDraft> draftNotifier,
    required ObjectRef<int?> boundUserIdRef,
    required ObjectRef<String?> boundSignatureRef,
  }) {
    final String signature = _signature(profile.settings);
    if (boundUserIdRef.value == profile.userId &&
        boundSignatureRef.value == signature) {
      return;
    }
    boundUserIdRef.value = profile.userId;
    boundSignatureRef.value = signature;
    final _TtsDraft draft = _TtsDraft.fromSettings(profile.settings);
    draftNotifier.value = draft;
    _scheduleApplyDraftToTtsController(ref: ref, draft: draft);
  }

  String _signature(UserStudySettings settings) {
    return '${settings.ttsVoiceId}|${settings.ttsSpeechRate}|${settings.ttsPitch}|${settings.ttsVolume}';
  }

  bool _hasChanges({
    required UserStudySettings profileSettings,
    required _TtsDraft draft,
  }) {
    if (profileSettings.ttsVoiceId != draft.voiceId) {
      return true;
    }
    if (profileSettings.ttsSpeechRate != draft.speechRate) {
      return true;
    }
    if (profileSettings.ttsPitch != draft.pitch) {
      return true;
    }
    if (profileSettings.ttsVolume != draft.volume) {
      return true;
    }
    return false;
  }

  void _updateDraft(
    _TtsDraft draft, {
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<_TtsDraft> draftNotifier,
    required ValueNotifier<bool> useDefaultTestTextNotifier,
    required TextEditingController testTextController,
    bool triggerLivePreview = true,
  }) {
    draftNotifier.value = draft;
    _applyDraftToTtsController(ref: ref, draft: draft);
    if (!triggerLivePreview) {
      return;
    }
    _emitLivePreviewIntent(
      context: context,
      ref: ref,
      draftNotifier: draftNotifier,
      useDefaultTestTextNotifier: useDefaultTestTextNotifier,
      testTextController: testTextController,
    );
  }

  void _applyDraftToTtsController({
    required WidgetRef ref,
    required _TtsDraft draft,
  }) {
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    controller.applyVoiceSettings(
      voiceId: draft.voiceId,
      speechRate: draft.speechRate,
      pitch: draft.pitch,
      volume: draft.volume,
      clearVoiceId: draft.voiceId == null,
    );
  }

  void _scheduleApplyDraftToTtsController({
    required WidgetRef ref,
    required _TtsDraft draft,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyDraftToTtsController(ref: ref, draft: draft);
    });
  }

  void _emitLivePreviewIntent({
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<_TtsDraft> draftNotifier,
    required ValueNotifier<bool> useDefaultTestTextNotifier,
    required TextEditingController testTextController,
  }) {
    final _TtsDraft draft = draftNotifier.value;
    final String text = _resolvePreviewText(
      context: context,
      ref: ref,
      draftNotifier: draftNotifier,
      useDefaultTestTextNotifier: useDefaultTestTextNotifier,
      testTextController: testTextController,
    );
    if (text.isEmpty) {
      return;
    }
    final TtsState ttsState = ref.read(ttsControllerProvider);
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    controller.queueLivePreview(
      previewText: text,
      voiceId: draft.voiceId,
      speechRate: draft.speechRate,
      pitch: draft.pitch,
      volume: draft.volume,
      isPreviewActive: ttsState.engine.status.isReading,
    );
  }

  Future<void> _previewVoice({
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<_TtsDraft> draftNotifier,
    required ValueNotifier<bool> useDefaultTestTextNotifier,
    required ValueNotifier<String?> customTestTextErrorNotifier,
    required TextEditingController testTextController,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!useDefaultTestTextNotifier.value) {
      final String customText = StringUtils.normalize(testTextController.text);
      if (customText.isEmpty) {
        customTestTextErrorNotifier.value = l10n.profileVoiceTestCustomRequired;
        _showVoiceTestValidationError(
          context: context,
          message: l10n.profileVoiceTestCustomRequired,
        );
        return;
      }
    }
    customTestTextErrorNotifier.value = null;
    final _TtsDraft draft = draftNotifier.value;
    final String text = _resolvePreviewText(
      context: context,
      ref: ref,
      draftNotifier: draftNotifier,
      useDefaultTestTextNotifier: useDefaultTestTextNotifier,
      testTextController: testTextController,
    );
    if (text.isEmpty) {
      return;
    }
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    await controller.previewWithConfig(
      previewText: text,
      voiceId: draft.voiceId,
      speechRate: draft.speechRate,
      pitch: draft.pitch,
      volume: draft.volume,
    );
  }
}

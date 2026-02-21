// quality-guard: allow-large-file - profile TTS settings widget groups draft model, sliders, and save flow for cohesive maintenance.
// quality-guard: allow-large-class - state class keeps draft binding, voice preview, and save orchestration in one place for this screen section.
// quality-guard: allow-long-function - declarative settings layout kept in one build unit to preserve alignment and hierarchy.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../core/utils/string_utils.dart';
import '../../model/profile_models.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../../../tts/model/tts_constants.dart';
import '../../../tts/model/tts_models.dart';
import '../../../tts/viewmodel/tts_state.dart';
import '../../../tts/viewmodel/tts_viewmodel.dart';
import 'settings_common_widgets.dart';

class ProfileTtsVoiceSettingsSection extends ConsumerStatefulWidget {
  const ProfileTtsVoiceSettingsSection({super.key});

  @override
  ConsumerState<ProfileTtsVoiceSettingsSection> createState() {
    return _ProfileTtsVoiceSettingsSectionState();
  }
}

class _ProfileTtsVoiceSettingsSectionState
    extends ConsumerState<ProfileTtsVoiceSettingsSection> {
  late final ValueNotifier<_TtsDraft> _draftNotifier;
  late final ValueNotifier<bool> _useDefaultTestTextNotifier;
  late final ValueNotifier<String?> _customTestTextErrorNotifier;
  late final TextEditingController _testTextController;
  int? _boundUserId;
  String? _boundSignature;

  @override
  void initState() {
    super.initState();
    _draftNotifier = ValueNotifier<_TtsDraft>(_TtsDraft.initial());
    _useDefaultTestTextNotifier = ValueNotifier<bool>(true);
    _customTestTextErrorNotifier = ValueNotifier<String?>(null);
    _testTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapVoices());
    });
  }

  @override
  void dispose() {
    _testTextController.dispose();
    _useDefaultTestTextNotifier.dispose();
    _customTestTextErrorNotifier.dispose();
    _draftNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserProfile> profileState = ref.watch(
      profileControllerProvider,
    );
    return profileState.when(
      data: _buildDataState,
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildDataState(UserProfile profile) {
    _bindDraft(profile);
    final TtsState ttsState = ref.watch(ttsControllerProvider);
    final TtsEngineState engine = ttsState.engine;
    final bool isInputDisabled = _isVoiceInputDisabled(engine);
    final bool isSaving = ref.watch(profileControllerProvider).isLoading;
    final bool isTesting = engine.status.isReading;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<_TtsDraft>(
      valueListenable: _draftNotifier,
      builder: (context, draft, _) {
        final List<TtsVoiceOption> dropdownVoices = _resolveUniqueVoices(
          _resolveKoreanVoices(engine.voices),
        );
        final int? dropdownVoiceIndex = _resolveDropdownVoiceIndex(
          draftVoiceId: draft.voiceId,
          voices: dropdownVoices,
        );
        final String defaultTestText = _resolveDefaultTestText(
          draft: draft,
          voices: engine.voices,
          l10n: l10n,
        );
        final bool hasChanges = _hasChanges(
          profileSettings: profile.settings,
          draft: draft,
        );
        return LwCard(
          variant: AppCardVariant.elevated,
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(
              _VoiceSettingsLayoutConstants.cardPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionTitleRow(
                  title: l10n.voiceSettingsSectionTitle,
                  icon: Icons.record_voice_over_rounded,
                  onRefresh: _resolveRefreshHandler(engine),
                ),
                const SettingsGroupDivider(),
                _VoiceSettingLabel(title: l10n.selectKoreanVoiceLabel),
                const SizedBox(
                  height: _VoiceSettingsLayoutConstants.subsectionGap,
                ),
                Text(
                  l10n.koreanVoicesCount(dropdownVoices.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: _VoiceSettingsLayoutConstants.itemGap),
                LwSelectBox<int?>(
                  key: ValueKey<int?>(dropdownVoiceIndex),
                  value: dropdownVoiceIndex,
                  onChanged: isInputDisabled
                      ? null
                      : (voiceIndex) {
                          final String? selectedVoiceId =
                              _resolveVoiceIdByDropdownIndex(
                                voiceIndex: voiceIndex,
                                voices: dropdownVoices,
                              );
                          _updateDraft(
                            draft.copyWith(
                              voiceId: selectedVoiceId,
                              clearVoiceId: selectedVoiceId == null,
                            ),
                          );
                        },
                  options: _buildVoiceItems(l10n: l10n, voices: dropdownVoices),
                ),
                const SizedBox(
                  height: _VoiceSettingsLayoutConstants.groupItemGap,
                ),
                _TtsSliderRow(
                  label: l10n.speedLabel,
                  value: draft.speechRate,
                  min: UserStudySettings.minTtsSpeechRate,
                  max: UserStudySettings.maxTtsSpeechRate,
                  onChanged: isInputDisabled
                      ? null
                      : (value) {
                          _updateDraft(
                            draft.copyWith(speechRate: value),
                            triggerLivePreview: false,
                          );
                        },
                  onChangeEnd: isInputDisabled
                      ? null
                      : (_) {
                          _emitLivePreviewIntent();
                        },
                ),
                const SizedBox(
                  height: _VoiceSettingsLayoutConstants.groupItemGap,
                ),
                _TtsSliderRow(
                  label: l10n.pitchLabel,
                  value: draft.pitch,
                  min: UserStudySettings.minTtsPitch,
                  max: UserStudySettings.maxTtsPitch,
                  onChanged: isInputDisabled
                      ? null
                      : (value) {
                          _updateDraft(
                            draft.copyWith(pitch: value),
                            triggerLivePreview: false,
                          );
                        },
                  onChangeEnd: isInputDisabled
                      ? null
                      : (_) {
                          _emitLivePreviewIntent();
                        },
                ),
                const SizedBox(
                  height: _VoiceSettingsLayoutConstants.groupItemGap,
                ),
                _TtsSliderRow(
                  label: l10n.volumeLabel,
                  value: draft.volume,
                  min: UserStudySettings.minTtsVolume,
                  max: UserStudySettings.maxTtsVolume,
                  onChanged: isInputDisabled
                      ? null
                      : (value) {
                          _updateDraft(
                            draft.copyWith(volume: value),
                            triggerLivePreview: false,
                          );
                        },
                  onChangeEnd: isInputDisabled
                      ? null
                      : (_) {
                          _emitLivePreviewIntent();
                        },
                ),
                const SizedBox(
                  height: _VoiceSettingsLayoutConstants.groupItemGap,
                ),
                _VoiceTestSection(
                  l10n: l10n,
                  useDefaultTestTextNotifier: _useDefaultTestTextNotifier,
                  customTestTextErrorNotifier: _customTestTextErrorNotifier,
                  testTextController: _testTextController,
                  defaultTestText: defaultTestText,
                  isInputDisabled: isInputDisabled,
                ),
                const SizedBox(
                  height: _VoiceSettingsLayoutConstants.actionRowTopGap,
                ),
                _VoiceSettingsActionRow(
                  testVoiceLabel: l10n.profileVoiceTestButtonLabel,
                  saveLabel: l10n.profileSaveSettingsLabel,
                  canTestVoice: !isInputDisabled && !isTesting,
                  canSaveSettings: hasChanges && !isSaving,
                  onTestVoicePressed: _previewVoice,
                  onSavePressed: () {
                    unawaited(_saveGlobalVoiceSettings(profile.settings));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isVoiceInputDisabled(TtsEngineState engine) {
    return engine.status.isLoadingVoices || engine.status.isInitializing;
  }

  VoidCallback? _resolveRefreshHandler(TtsEngineState engine) {
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

  Future<void> _bootstrapVoices() async {
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    final TtsState state = ref.read(ttsControllerProvider);
    if (state.engine.isInitialized && _hasKoreanVoice(state.engine.voices)) {
      return;
    }
    await controller.initialize();
    if (!mounted) {
      return;
    }
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

  void _bindDraft(UserProfile profile) {
    final String signature = _signature(profile.settings);
    if (_boundUserId == profile.userId && _boundSignature == signature) {
      return;
    }
    _boundUserId = profile.userId;
    _boundSignature = signature;
    final _TtsDraft draft = _TtsDraft.fromSettings(profile.settings);
    _draftNotifier.value = draft;
    _scheduleApplyDraftToTtsController(draft);
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

  void _updateDraft(_TtsDraft draft, {bool triggerLivePreview = true}) {
    _draftNotifier.value = draft;
    _applyDraftToTtsController(draft);
    if (!triggerLivePreview) {
      return;
    }
    _emitLivePreviewIntent();
  }

  void _applyDraftToTtsController(_TtsDraft draft) {
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    controller.applyVoiceSettings(
      voiceId: draft.voiceId,
      speechRate: draft.speechRate,
      pitch: draft.pitch,
      volume: draft.volume,
      clearVoiceId: draft.voiceId == null,
    );
  }

  void _scheduleApplyDraftToTtsController(_TtsDraft draft) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _applyDraftToTtsController(draft);
    });
  }

  void _emitLivePreviewIntent() {
    final _TtsDraft draft = _draftNotifier.value;
    final String text = _resolvePreviewText();
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

  Future<void> _previewVoice() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_useDefaultTestTextNotifier.value) {
      final String customText = StringUtils.normalize(_testTextController.text);
      if (customText.isEmpty) {
        _customTestTextErrorNotifier.value =
            l10n.profileVoiceTestCustomRequired;
        _showVoiceTestValidationError(l10n.profileVoiceTestCustomRequired);
        return;
      }
    }
    _customTestTextErrorNotifier.value = null;
    final _TtsDraft draft = _draftNotifier.value;
    final String text = _resolvePreviewText();
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

  void _showVoiceTestValidationError(String message) {
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

  String _resolvePreviewText() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (_useDefaultTestTextNotifier.value) {
      final TtsState ttsState = ref.read(ttsControllerProvider);
      final _TtsDraft draft = _draftNotifier.value;
      final String defaultText = _resolveDefaultTestText(
        draft: draft,
        voices: ttsState.engine.voices,
        l10n: l10n,
      );
      return StringUtils.normalize(defaultText);
    }
    return StringUtils.normalize(_testTextController.text);
  }

  String _resolveDefaultTestText({
    required _TtsDraft draft,
    required List<TtsVoiceOption> voices,
    required AppLocalizations l10n,
  }) {
    final String languageCode = _resolvePreferredLanguageCode(
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
    return _resolveAppLocaleLanguageCode();
  }

  String _resolveAppLocaleLanguageCode() {
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

  Future<void> _saveGlobalVoiceSettings(UserStudySettings baseSettings) async {
    await ref.read(ttsControllerProvider.notifier).stopReading();
    final _TtsDraft draft = _draftNotifier.value;
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

class _VoiceTestSection extends StatelessWidget {
  const _VoiceTestSection({
    required this.l10n,
    required this.useDefaultTestTextNotifier,
    required this.customTestTextErrorNotifier,
    required this.testTextController,
    required this.defaultTestText,
    required this.isInputDisabled,
  });

  final AppLocalizations l10n;
  final ValueNotifier<bool> useDefaultTestTextNotifier;
  final ValueNotifier<String?> customTestTextErrorNotifier;
  final TextEditingController testTextController;
  final String defaultTestText;
  final bool isInputDisabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: useDefaultTestTextNotifier,
      builder: (context, useDefaultText, _) {
        final bool canEditInput = !useDefaultText && !isInputDisabled;
        final String toggleLabel = useDefaultText
            ? l10n.profileVoiceTestUseDefaultLabel
            : l10n.profileVoiceTestUseCustomLabel;
        final IconData toggleIcon = useDefaultText
            ? Icons.auto_awesome_rounded
            : Icons.edit_note_rounded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _VoiceSettingLabel(
                    title: l10n.profileVoiceTestModeLabel,
                  ),
                ),
                SizedBox(
                  width: _VoiceTestSectionConstants.toggleButtonWidth,
                  child: OutlinedButton.icon(
                    onPressed: isInputDisabled
                        ? null
                        : () {
                            customTestTextErrorNotifier.value = null;
                            useDefaultTestTextNotifier.value = !useDefaultText;
                          },
                    icon: Icon(toggleIcon),
                    label: Text(toggleLabel),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _VoiceSettingsLayoutConstants.itemGap),
            ValueListenableBuilder<String?>(
              valueListenable: customTestTextErrorNotifier,
              builder: (context, customTextError, _) {
                return LwTextArea(
                  key: ValueKey<String>(
                    'voice-test-panel-$useDefaultText-$defaultTestText',
                  ),
                  controller: useDefaultText ? null : testTextController,
                  initialValue: useDefaultText ? defaultTestText : null,
                  enabled: useDefaultText ? true : canEditInput,
                  readOnly: useDefaultText,
                  maxLines: _VoiceTestSectionConstants.textPanelMaxLines,
                  minLines: _VoiceTestSectionConstants.textPanelMinLines,
                  labelText: useDefaultText
                      ? l10n.profileVoiceTestUseDefaultLabel
                      : l10n.profileVoiceTestInputLabel,
                  hintText: useDefaultText ? null : l10n.profileVoiceTestHint,
                  errorText: useDefaultText ? null : customTextError,
                  onChanged: useDefaultText
                      ? null
                      : (_) {
                          if (customTextError == null) {
                            return;
                          }
                          customTestTextErrorNotifier.value = null;
                        },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _VoiceSettingsActionRow extends StatelessWidget {
  const _VoiceSettingsActionRow({
    required this.testVoiceLabel,
    required this.saveLabel,
    required this.canTestVoice,
    required this.canSaveSettings,
    required this.onTestVoicePressed,
    required this.onSavePressed,
  });

  final String testVoiceLabel;
  final String saveLabel;
  final bool canTestVoice;
  final bool canSaveSettings;
  final VoidCallback onTestVoicePressed;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _VoiceActionButton(
              label: testVoiceLabel,
              enabled: canTestVoice,
              onPressed: onTestVoicePressed,
              tonal: true,
            ),
            const SizedBox(
              width: _VoiceSettingsLayoutConstants.actionButtonGap,
            ),
            _VoiceActionButton(
              label: saveLabel,
              enabled: canSaveSettings,
              onPressed: onSavePressed,
              tonal: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceActionButton extends StatelessWidget {
  const _VoiceActionButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    required this.tonal,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ButtonStyle style = FilledButton.styleFrom(
      minimumSize: const Size(0, AppSizes.size48),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingLg),
      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
    if (tonal) {
      return FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: Text(label),
      );
    }
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: style,
      child: Text(label),
    );
  }
}

class _VoiceTestSectionConstants {
  const _VoiceTestSectionConstants._();

  static const int textPanelMinLines = 4;
  static const int textPanelMaxLines = 5;
  static const double toggleButtonWidth = AppSizes.size144 + AppSizes.size32;
}

class _VoiceSettingsLayoutConstants {
  const _VoiceSettingsLayoutConstants._();

  static const double cardPadding = AppSizes.spacingMd;
  static const double subsectionGap = AppSizes.spacingXs;
  static const double itemGap = AppSizes.spacingSm;
  static const double groupItemGap = AppSizes.spacingMd;
  static const double actionRowTopGap = AppSizes.spacingMd;
  static const double actionButtonGap = AppSizes.spacingSm;
}

class _VoiceSettingLabel extends StatelessWidget {
  const _VoiceSettingLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _VoiceSettingHeader extends StatelessWidget {
  const _VoiceSettingHeader({
    required this.icon,
    required this.title,
    required this.containerColor,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final Color containerColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SettingTitleRow(
      icon: icon,
      title: title,
      containerColor: containerColor,
      iconColor: iconColor,
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    required this.icon,
    required this.onRefresh,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: _VoiceSettingHeader(
            icon: icon,
            title: title,
            containerColor: colorScheme.primaryContainer,
            iconColor: colorScheme.onPrimaryContainer,
          ),
        ),
        LwIconButton(
          onPressed: onRefresh,
          tooltip: AppLocalizations.of(context)!.loadKoreanVoices,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }
}

class _TtsSliderRow extends StatelessWidget {
  const _TtsSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final String valueText = value.toStringAsFixed(2);
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: _VoiceSettingLabel(title: label)),
            const SizedBox(width: _VoiceSettingsLayoutConstants.subsectionGap),
            Text(
              valueText,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: _VoiceSettingsLayoutConstants.subsectionGap),
        LwSliderInput(
          value: value.clamp(min, max),
          min: min,
          max: max,
          label: null,
          displayValueText: valueText,
          divisions: TtsConstants.sliderDivisions,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}

class _TtsDraft {
  const _TtsDraft({
    required this.voiceId,
    required this.speechRate,
    required this.pitch,
    required this.volume,
  });

  final String? voiceId;
  final double speechRate;
  final double pitch;
  final double volume;

  factory _TtsDraft.initial() {
    return const _TtsDraft(
      voiceId: null,
      speechRate: UserStudySettings.defaultTtsSpeechRate,
      pitch: UserStudySettings.defaultTtsPitch,
      volume: UserStudySettings.defaultTtsVolume,
    );
  }

  factory _TtsDraft.fromSettings(UserStudySettings settings) {
    return _TtsDraft(
      voiceId: settings.ttsVoiceId,
      speechRate: settings.ttsSpeechRate,
      pitch: settings.ttsPitch,
      volume: settings.ttsVolume,
    );
  }

  _TtsDraft copyWith({
    String? voiceId,
    bool clearVoiceId = false,
    double? speechRate,
    double? pitch,
    double? volume,
  }) {
    final String? nextVoiceId = clearVoiceId ? null : (voiceId ?? this.voiceId);
    return _TtsDraft(
      voiceId: nextVoiceId,
      speechRate: UserStudySettings.normalizeTtsSpeechRate(
        speechRate ?? this.speechRate,
      ),
      pitch: UserStudySettings.normalizeTtsPitch(pitch ?? this.pitch),
      volume: UserStudySettings.normalizeTtsVolume(volume ?? this.volume),
    );
  }
}

class _LanguageCode {
  const _LanguageCode._();

  static const String en = 'en';
  static const String vi = 'vi';
  static const String ko = 'ko';
  static const String ja = 'ja';
}

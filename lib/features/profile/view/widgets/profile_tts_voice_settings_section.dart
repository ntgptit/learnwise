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
  late final TextEditingController _testTextController;
  int? _boundUserId;
  String? _boundSignature;

  @override
  void initState() {
    super.initState();
    _draftNotifier = ValueNotifier<_TtsDraft>(_TtsDraft.initial());
    _useDefaultTestTextNotifier = ValueNotifier<bool>(true);
    _testTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapVoices());
    });
  }

  @override
  void dispose() {
    _testTextController.dispose();
    _useDefaultTestTextNotifier.dispose();
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
        final String defaultTestText = _resolveDefaultTestText(
          draft: draft,
          voices: engine.voices,
          l10n: l10n,
        );
        final bool hasChanges = _hasChanges(
          profileSettings: profile.settings,
          draft: draft,
        );
        return AppCard(
          variant: AppCardVariant.elevated,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionTitleRow(
                  title: l10n.voiceSettingsSectionTitle,
                  onRefresh: _resolveRefreshHandler(engine),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                Text(
                  l10n.koreanVoicesCount(engine.voices.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSizes.spacingSm),
                DropdownButtonFormField<String?>(
                  key: ValueKey<String?>(draft.voiceId),
                  initialValue: draft.voiceId,
                  onChanged: isInputDisabled
                      ? null
                      : (voiceId) {
                          _updateDraft(
                            draft.copyWith(
                              voiceId: voiceId,
                              clearVoiceId: voiceId == null,
                            ),
                          );
                        },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ).copyWith(labelText: l10n.selectKoreanVoiceLabel),
                  items: _buildVoiceItems(l10n: l10n, voices: engine.voices),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                _TtsSliderRow(
                  label: l10n.speedLabel,
                  value: draft.speechRate,
                  min: UserStudySettings.minTtsSpeechRate,
                  max: UserStudySettings.maxTtsSpeechRate,
                  onChanged: isInputDisabled
                      ? null
                      : (value) {
                          _updateDraft(draft.copyWith(speechRate: value));
                        },
                ),
                const SizedBox(height: AppSizes.spacingSm),
                _TtsSliderRow(
                  label: l10n.pitchLabel,
                  value: draft.pitch,
                  min: UserStudySettings.minTtsPitch,
                  max: UserStudySettings.maxTtsPitch,
                  onChanged: isInputDisabled
                      ? null
                      : (value) {
                          _updateDraft(draft.copyWith(pitch: value));
                        },
                ),
                const SizedBox(height: AppSizes.spacingSm),
                _TtsSliderRow(
                  label: l10n.volumeLabel,
                  value: draft.volume,
                  min: UserStudySettings.minTtsVolume,
                  max: UserStudySettings.maxTtsVolume,
                  onChanged: isInputDisabled
                      ? null
                      : (value) {
                          _updateDraft(draft.copyWith(volume: value));
                        },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                _VoiceTestSection(
                  l10n: l10n,
                  useDefaultTestTextNotifier: _useDefaultTestTextNotifier,
                  testTextController: _testTextController,
                  defaultTestText: defaultTestText,
                  isInputDisabled: isInputDisabled,
                  isTesting: isTesting,
                  onPreviewPressed: _previewVoice,
                ),
                const SizedBox(height: AppSizes.spacingLg),
                Center(
                  child: SizedBox(
                    height: AppSizes.size48,
                    child: FilledButton(
                      onPressed: !hasChanges || isSaving
                          ? null
                          : () => _saveGlobalVoiceSettings(profile.settings),
                      child: Text(l10n.profileSaveSettingsLabel),
                    ),
                  ),
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
    return controller.loadVoices;
  }

  List<DropdownMenuItem<String?>> _buildVoiceItems({
    required AppLocalizations l10n,
    required List<TtsVoiceOption> voices,
  }) {
    return <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(
        value: null,
        child: Text(l10n.systemDefaultVoice),
      ),
      ...voices.asMap().entries.map((entry) {
        final int index = entry.key + 1;
        final TtsVoiceOption voice = entry.value;
        final String alias = l10n.koreanVoiceAlias(
          index.toString().padLeft(
            TtsConstants.voiceAliasPadWidth,
            TtsConstants.voiceAliasPadChar,
          ),
        );
        return DropdownMenuItem<String?>(
          value: voice.id,
          child: Text('$alias - ${voice.displayLabel}'),
        );
      }),
    ];
  }

  Future<void> _bootstrapVoices() async {
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    final TtsState state = ref.read(ttsControllerProvider);
    if (state.engine.isInitialized && state.engine.voices.isNotEmpty) {
      return;
    }
    await controller.initialize();
    if (!mounted) {
      return;
    }
    final TtsState initializedState = ref.read(ttsControllerProvider);
    if (initializedState.engine.voices.isNotEmpty) {
      return;
    }
    await controller.loadVoices();
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

  void _updateDraft(_TtsDraft draft) {
    _draftNotifier.value = draft;
    _applyDraftToTtsController(draft);
  }

  void _applyDraftToTtsController(_TtsDraft draft) {
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    controller.selectVoice(draft.voiceId);
    controller.setSpeechRate(draft.speechRate);
    controller.setPitch(draft.pitch);
    controller.setVolume(draft.volume);
  }

  void _scheduleApplyDraftToTtsController(_TtsDraft draft) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _applyDraftToTtsController(draft);
    });
  }

  Future<void> _previewVoice() async {
    final _TtsDraft draft = _draftNotifier.value;
    final String text = _resolvePreviewText();
    if (text.isEmpty) {
      return;
    }
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    controller.selectVoice(draft.voiceId);
    controller.setSpeechRate(draft.speechRate);
    controller.setPitch(draft.pitch);
    controller.setVolume(draft.volume);
    await controller.initialize();
    controller.setInputText(text);
    await controller.readText();
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
    required this.testTextController,
    required this.defaultTestText,
    required this.isInputDisabled,
    required this.isTesting,
    required this.onPreviewPressed,
  });

  final AppLocalizations l10n;
  final ValueNotifier<bool> useDefaultTestTextNotifier;
  final TextEditingController testTextController;
  final String defaultTestText;
  final bool isInputDisabled;
  final bool isTesting;
  final VoidCallback onPreviewPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: useDefaultTestTextNotifier,
      builder: (context, useDefaultText, _) {
        final bool canEditInput = !useDefaultText && !isInputDisabled;
        final bool canPreview = !isInputDisabled && !isTesting;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.profileVoiceTestModeLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSizes.spacingSm),
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: true,
                  label: Text(l10n.profileVoiceTestUseDefaultLabel),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(l10n.profileVoiceTestUseCustomLabel),
                ),
              ],
              selected: <bool>{useDefaultText},
              onSelectionChanged: (selection) {
                useDefaultTestTextNotifier.value = selection.first;
              },
              showSelectedIcon: false,
            ),
            const SizedBox(height: AppSizes.spacingSm),
            if (!useDefaultText)
              TextField(
                controller: testTextController,
                enabled: canEditInput,
                maxLines: 3,
                minLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.profileVoiceTestInputLabel,
                  hintText: l10n.profileVoiceTestHint,
                ),
              ),
            if (useDefaultText) ...<Widget>[
              const SizedBox(height: AppSizes.spacingXs),
              Text(
                defaultTestText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSizes.spacingSm),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: canPreview ? onPreviewPressed : null,
                icon: const Icon(Icons.volume_up_rounded),
                label: Text(l10n.profileVoiceTestButtonLabel),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({required this.title, required this.onRefresh});

  final String title;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          tooltip: AppLocalizations.of(context)!.loadKoreanVoices,
          icon: const Icon(Icons.refresh_rounded),
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
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final String valueText = value.toStringAsFixed(2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Text(valueText),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: TtsConstants.sliderDivisions,
          onChanged: onChanged,
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

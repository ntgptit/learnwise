import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';
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
  int? _boundUserId;
  String? _boundSignature;

  @override
  void initState() {
    super.initState();
    _draftNotifier = ValueNotifier<_TtsDraft>(_TtsDraft.initial());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapVoices());
    });
  }

  @override
  void dispose() {
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

  // quality-guard: allow-long-function - declarative settings layout kept in one build unit to preserve alignment and hierarchy.
  Widget _buildDataState(UserProfile profile) {
    _bindDraft(profile);
    final TtsState ttsState = ref.watch(ttsControllerProvider);
    final TtsEngineState engine = ttsState.engine;
    final bool isInputDisabled = _isVoiceInputDisabled(engine);
    final bool isSaving = ref.watch(profileControllerProvider).isLoading;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<_TtsDraft>(
      valueListenable: _draftNotifier,
      builder: (context, draft, _) {
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
    _applyDraftToTtsController(draft);
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

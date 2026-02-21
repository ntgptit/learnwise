// quality-guard: allow-large-file - profile TTS settings widget groups draft model, sliders, and save flow for cohesive maintenance.
// quality-guard: allow-large-class - state class keeps draft binding, voice preview, and save orchestration in one place for this screen section.
// quality-guard: allow-long-function - declarative settings layout kept in one build unit to preserve alignment and hierarchy.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../../common/styles/app_sizes.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../../core/utils/string_utils.dart';
import '../../../../model/profile_models.dart';
import '../../../../viewmodel/profile_viewmodel.dart';
import '../../../../../tts/model/tts_constants.dart';
import '../../../../../tts/model/tts_models.dart';
import '../../../../../tts/viewmodel/tts_state.dart';
import '../../../../../tts/viewmodel/tts_viewmodel.dart';
import '../settings_common_widgets.dart';

part 'profile_tts_voice_settings_section_runtime.dart';
part 'profile_tts_voice_settings_section_text.dart';
part 'profile_tts_voice_settings_section_ui.dart';
part 'profile_tts_voice_settings_section_model.dart';

class ProfileTtsVoiceSettingsSection extends HookConsumerWidget {
  const ProfileTtsVoiceSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<_TtsDraft> draftNotifier = useValueNotifier<_TtsDraft>(
      _TtsDraft.initial(),
    );
    final ValueNotifier<bool> useDefaultTestTextNotifier =
        useValueNotifier<bool>(true);
    final ValueNotifier<String?> customTestTextErrorNotifier =
        useValueNotifier<String?>(null);
    final TextEditingController testTextController = useTextEditingController();
    final ObjectRef<int?> boundUserIdRef = useRef<int?>(null);
    final ObjectRef<String?> boundSignatureRef = useRef<String?>(null);
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_bootstrapVoices(ref: ref));
      });
      return null;
    }, const <Object?>[]);
    final AsyncValue<UserProfile> profileState = ref.watch(
      profileControllerProvider,
    );
    return profileState.when(
      data: (profile) {
        return _buildDataState(
          context: context,
          ref: ref,
          profile: profile,
          draftNotifier: draftNotifier,
          useDefaultTestTextNotifier: useDefaultTestTextNotifier,
          customTestTextErrorNotifier: customTestTextErrorNotifier,
          testTextController: testTextController,
          boundUserIdRef: boundUserIdRef,
          boundSignatureRef: boundSignatureRef,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildDataState({
    required BuildContext context,
    required WidgetRef ref,
    required UserProfile profile,
    required ValueNotifier<_TtsDraft> draftNotifier,
    required ValueNotifier<bool> useDefaultTestTextNotifier,
    required ValueNotifier<String?> customTestTextErrorNotifier,
    required TextEditingController testTextController,
    required ObjectRef<int?> boundUserIdRef,
    required ObjectRef<String?> boundSignatureRef,
  }) {
    _bindDraft(
      ref: ref,
      profile: profile,
      draftNotifier: draftNotifier,
      boundUserIdRef: boundUserIdRef,
      boundSignatureRef: boundSignatureRef,
    );
    final TtsState ttsState = ref.watch(ttsControllerProvider);
    final TtsEngineState engine = ttsState.engine;
    final bool isInputDisabled = _isVoiceInputDisabled(engine);
    final bool isSaving = ref.watch(profileControllerProvider).isLoading;
    final bool isTesting = engine.status.isReading;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<_TtsDraft>(
      valueListenable: draftNotifier,
      builder: (context, draft, _) {
        final List<TtsVoiceOption> dropdownVoices = _resolveUniqueVoices(
          _resolveKoreanVoices(engine.voices),
        );
        final int? dropdownVoiceIndex = _resolveDropdownVoiceIndex(
          draftVoiceId: draft.voiceId,
          voices: dropdownVoices,
        );
        final String defaultTestText = _resolveDefaultTestText(
          context: context,
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
                  onRefresh: _resolveRefreshHandler(ref: ref, engine: engine),
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
                            context: context,
                            ref: ref,
                            draftNotifier: draftNotifier,
                            useDefaultTestTextNotifier:
                                useDefaultTestTextNotifier,
                            testTextController: testTextController,
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
                            context: context,
                            ref: ref,
                            draftNotifier: draftNotifier,
                            useDefaultTestTextNotifier:
                                useDefaultTestTextNotifier,
                            testTextController: testTextController,
                            triggerLivePreview: false,
                          );
                        },
                  onChangeEnd: isInputDisabled
                      ? null
                      : (_) {
                          _emitLivePreviewIntent(
                            context: context,
                            ref: ref,
                            draftNotifier: draftNotifier,
                            useDefaultTestTextNotifier:
                                useDefaultTestTextNotifier,
                            testTextController: testTextController,
                          );
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
                            context: context,
                            ref: ref,
                            draftNotifier: draftNotifier,
                            useDefaultTestTextNotifier:
                                useDefaultTestTextNotifier,
                            testTextController: testTextController,
                            triggerLivePreview: false,
                          );
                        },
                  onChangeEnd: isInputDisabled
                      ? null
                      : (_) {
                          _emitLivePreviewIntent(
                            context: context,
                            ref: ref,
                            draftNotifier: draftNotifier,
                            useDefaultTestTextNotifier:
                                useDefaultTestTextNotifier,
                            testTextController: testTextController,
                          );
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
                            context: context,
                            ref: ref,
                            draftNotifier: draftNotifier,
                            useDefaultTestTextNotifier:
                                useDefaultTestTextNotifier,
                            testTextController: testTextController,
                            triggerLivePreview: false,
                          );
                        },
                  onChangeEnd: isInputDisabled
                      ? null
                      : (_) {
                          _emitLivePreviewIntent(
                            context: context,
                            ref: ref,
                            draftNotifier: draftNotifier,
                            useDefaultTestTextNotifier:
                                useDefaultTestTextNotifier,
                            testTextController: testTextController,
                          );
                        },
                ),
                const SizedBox(
                  height: _VoiceSettingsLayoutConstants.groupItemGap,
                ),
                _VoiceTestSection(
                  l10n: l10n,
                  useDefaultTestTextNotifier: useDefaultTestTextNotifier,
                  customTestTextErrorNotifier: customTestTextErrorNotifier,
                  testTextController: testTextController,
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
                  onTestVoicePressed: () {
                    unawaited(
                      _previewVoice(
                        context: context,
                        ref: ref,
                        draftNotifier: draftNotifier,
                        useDefaultTestTextNotifier: useDefaultTestTextNotifier,
                        customTestTextErrorNotifier:
                            customTestTextErrorNotifier,
                        testTextController: testTextController,
                      ),
                    );
                  },
                  onSavePressed: () {
                    unawaited(
                      _saveGlobalVoiceSettings(
                        ref: ref,
                        baseSettings: profile.settings,
                        draftNotifier: draftNotifier,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

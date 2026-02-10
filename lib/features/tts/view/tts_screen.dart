import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/icons.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../model/tts_constants.dart';
import '../model/tts_models.dart';
import '../model/tts_sample_text.dart';
import '../viewmodel/tts_state.dart';
import '../viewmodel/tts_viewmodel.dart';

class TtsScreen extends ConsumerStatefulWidget {
  const TtsScreen({super.key});

  @override
  ConsumerState<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends ConsumerState<TtsScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    ref.listen<String>(
      ttsControllerProvider.select((TtsState state) => state.inputText),
      (String? previous, String next) {
        if (_textController.text == next) {
          return;
        }
        _textController.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      },
    );

    final TtsState state = ref.watch(ttsControllerProvider);
    final TtsController controller = ref.read(ttsControllerProvider.notifier);
    final bool isReading = state.status.isReading;
    final bool isLoadingVoices = state.status.isLoadingVoices;
    final bool isInitializing = state.status.isInitializing;
    final List<TtsSampleText> samples = <TtsSampleText>[
      TtsSampleText(
        label: l10n.sampleLabelEn,
        text: l10n.sampleEnText,
        mode: TtsLanguageMode.english,
      ),
      TtsSampleText(
        label: l10n.sampleLabelKo,
        text: l10n.sampleKoText,
        mode: TtsLanguageMode.korean,
      ),
      TtsSampleText(
        label: l10n.sampleLabelAuto,
        text: l10n.sampleAutoText,
        mode: TtsLanguageMode.auto,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: TtsScreenTokens.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isInitializing) ...<Widget>[
                const LinearProgressIndicator(),
                const SizedBox(height: TtsScreenTokens.sectionSpacing),
              ],
              SectionTitle(title: l10n.inputSectionTitle),
              const SizedBox(height: TtsScreenTokens.sectionSpacing),
              DropdownButtonFormField<TtsLanguageMode>(
                key: ValueKey<TtsLanguageMode>(state.languageMode),
                initialValue: state.languageMode,
                onChanged: isReading
                    ? null
                    : (TtsLanguageMode? value) {
                        if (value == null) {
                          return;
                        }
                        controller.setLanguageMode(value);
                      },
                decoration: const InputDecoration(
                  border: TtsScreenTokens.formBorder,
                ).copyWith(labelText: l10n.languageLabel),
                items: <DropdownMenuItem<TtsLanguageMode>>[
                  DropdownMenuItem<TtsLanguageMode>(
                    value: TtsLanguageMode.auto,
                    child: Text(l10n.languageAuto),
                  ),
                  DropdownMenuItem<TtsLanguageMode>(
                    value: TtsLanguageMode.english,
                    child: Text(l10n.languageEnglish),
                  ),
                  DropdownMenuItem<TtsLanguageMode>(
                    value: TtsLanguageMode.korean,
                    child: Text(l10n.languageKorean),
                  ),
                ],
              ),
              const SizedBox(height: TtsScreenTokens.sectionSpacing),
              SectionTitle(title: l10n.koreanVoicesSectionTitle),
              const SizedBox(height: TtsScreenTokens.subsectionSpacing),
              OutlinedButton.icon(
                onPressed: isLoadingVoices ? null : controller.loadVoices,
                icon: const Icon(AppIcons.refresh),
                label: Text(
                  isLoadingVoices ? l10n.loadingVoices : l10n.loadKoreanVoices,
                ),
              ),
              const SizedBox(height: TtsScreenTokens.subsectionSpacing),
              Text(l10n.koreanVoicesCount(state.voices.length)),
              const SizedBox(height: TtsScreenTokens.subsectionSpacing),
              DropdownButtonFormField<String?>(
                key: ValueKey<String?>(state.selectedVoiceId),
                initialValue: state.selectedVoiceId,
                onChanged: isReading ? null : controller.selectVoice,
                decoration: const InputDecoration(
                  border: TtsScreenTokens.formBorder,
                ).copyWith(labelText: l10n.selectKoreanVoiceLabel),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.systemDefaultVoice),
                  ),
                  ...state.voices.asMap().entries.map((
                    MapEntry<int, TtsVoiceOption> entry,
                  ) {
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
                      child: Text(alias),
                    );
                  }),
                ],
              ),
              const SizedBox(height: TtsScreenTokens.sectionSpacing),
              SectionTitle(title: l10n.sampleSectionTitle),
              const SizedBox(height: TtsScreenTokens.subsectionSpacing),
              Wrap(
                spacing: TtsScreenTokens.subsectionSpacing,
                runSpacing: TtsScreenTokens.subsectionSpacing,
                children: samples
                    .map(
                      (TtsSampleText sample) => ActionChip(
                        label: Text(sample.label),
                        onPressed: isReading
                            ? null
                            : () => controller.setSample(sample),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: TtsScreenTokens.sectionSpacing),
              SectionTitle(title: l10n.voiceSettingsSectionTitle),
              const SizedBox(height: TtsScreenTokens.subsectionSpacing),
              _VoiceSlider(
                label: l10n.speedLabel,
                value: state.speechRate,
                min: TtsConstants.speechRateMin,
                max: TtsConstants.speechRateMax,
                onChanged: isReading ? null : controller.setSpeechRate,
              ),
              _VoiceSlider(
                label: l10n.pitchLabel,
                value: state.pitch,
                min: TtsConstants.pitchMin,
                max: TtsConstants.pitchMax,
                onChanged: isReading ? null : controller.setPitch,
              ),
              _VoiceSlider(
                label: l10n.volumeLabel,
                value: state.volume,
                min: TtsConstants.volumeMin,
                max: TtsConstants.volumeMax,
                onChanged: isReading ? null : controller.setVolume,
              ),
              const SizedBox(height: TtsScreenTokens.sectionSpacing),
              TextField(
                controller: _textController,
                minLines: TtsScreenTokens.inputMinLines,
                maxLines: TtsScreenTokens.inputMaxLines,
                onChanged: controller.setInputText,
                decoration: const InputDecoration(
                  border: TtsScreenTokens.formBorder,
                ).copyWith(hintText: l10n.inputHint),
              ),
              const SizedBox(height: TtsScreenTokens.actionSpacing),
              FilledButton.icon(
                onPressed: isReading ? null : controller.readText,
                icon: const Icon(AppIcons.volumeUp),
                label: Text(l10n.readButton),
              ),
              const SizedBox(height: TtsScreenTokens.subsectionSpacing),
              OutlinedButton.icon(
                onPressed: isReading ? controller.stopReading : null,
                icon: const Icon(AppIcons.stop),
                label: Text(l10n.stopButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceSlider extends StatelessWidget {
  const _VoiceSlider({
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
    return Row(
      children: <Widget>[
        SizedBox(width: TtsScreenTokens.sliderLabelWidth, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: TtsConstants.sliderDivisions,
            label: value.toStringAsFixed(TtsConstants.sliderPrecision),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: TtsScreenTokens.sliderValueWidth,
          child: Text(
            value.toStringAsFixed(TtsConstants.sliderPrecision),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

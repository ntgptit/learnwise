import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/tts_const.dart';
import '../model/tts_models.dart';

part 'tts_state.freezed.dart';

@freezed
sealed class TtsStatus with _$TtsStatus {
  const factory TtsStatus.idle() = _TtsStatusIdle;
  const factory TtsStatus.initializing() = _TtsStatusInitializing;
  const factory TtsStatus.loadingVoices() = _TtsStatusLoadingVoices;
  const factory TtsStatus.reading() = _TtsStatusReading;
}

@freezed
sealed class TtsState with _$TtsState {
  const factory TtsState({
    required String inputText,
    required TtsLanguageMode languageMode,
    required double speechRate,
    required double pitch,
    required double volume,
    required List<TtsVoiceOption> voices,
    required String? selectedVoiceId,
    required TtsStatus status,
    required bool isInitialized,
  }) = _TtsState;

  factory TtsState.initial() {
    return const TtsState(
      inputText: '',
      languageMode: TtsLanguageMode.auto,
      speechRate: TtsConst.defaultSpeechRate,
      pitch: TtsConst.defaultPitch,
      volume: TtsConst.defaultVolume,
      voices: <TtsVoiceOption>[],
      selectedVoiceId: null,
      status: TtsStatus.idle(),
      isInitialized: false,
    );
  }
}

extension TtsStatusX on TtsStatus {
  bool get isIdle => switch (this) {
    _TtsStatusIdle() => true,
    _ => false,
  };

  bool get isInitializing => switch (this) {
    _TtsStatusInitializing() => true,
    _ => false,
  };

  bool get isLoadingVoices => switch (this) {
    _TtsStatusLoadingVoices() => true,
    _ => false,
  };

  bool get isReading => switch (this) {
    _TtsStatusReading() => true,
    _ => false,
  };
}

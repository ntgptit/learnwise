import 'package:freezed_annotation/freezed_annotation.dart';

import '../model/tts_constants.dart';
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
    required TtsConfig config,
    required TtsEngineState engine,
  }) = _TtsState;

  factory TtsState.initial() {
    return TtsState(
      config: TtsConfig.initial(),
      engine: TtsEngineState.initial(),
    );
  }
}

@freezed
sealed class TtsConfig with _$TtsConfig {
  const factory TtsConfig({
    required TtsLanguageMode languageMode,
    required double speechRate,
    required double pitch,
    required double volume,
    required String? selectedVoiceId,
  }) = _TtsConfig;

  factory TtsConfig.initial() {
    return const TtsConfig(
      languageMode: TtsLanguageMode.auto,
      speechRate: TtsConstants.defaultSpeechRate,
      pitch: TtsConstants.defaultPitch,
      volume: TtsConstants.defaultVolume,
      selectedVoiceId: null,
    );
  }
}

@freezed
sealed class TtsEngineState with _$TtsEngineState {
  const factory TtsEngineState({
    required List<TtsVoiceOption> voices,
    required TtsStatus status,
    required bool isInitialized,
  }) = _TtsEngineState;

  factory TtsEngineState.initial() {
    return const TtsEngineState(
      voices: <TtsVoiceOption>[],
      status: TtsStatus.idle(),
      isInitialized: false,
    );
  }
}

extension TtsStateLegacyViewX on TtsState {
  TtsLanguageMode get languageMode => config.languageMode;
  double get speechRate => config.speechRate;
  double get pitch => config.pitch;
  double get volume => config.volume;
  String? get selectedVoiceId => config.selectedVoiceId;
  List<TtsVoiceOption> get voices => engine.voices;
  TtsStatus get status => engine.status;
  bool get isInitialized => engine.isInitialized;
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

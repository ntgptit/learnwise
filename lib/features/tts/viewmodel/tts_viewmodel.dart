import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_error_mapper.dart';
import '../../../core/error/error_code.dart';
import '../../../core/utils/string_utils.dart';
import '../model/tts_constants.dart';
import '../model/tts_models.dart';
import '../model/tts_sample_text.dart';
import '../repository/tts_repository.dart';
import '../repository/tts_service.dart';
import 'tts_state.dart';

part 'tts_viewmodel.g.dart';

@Riverpod(keepAlive: true)
TtsRepository ttsRepository(Ref ref) {
  final TtsRepository repository = TtsService();
  ref.onDispose(() {
    unawaited(repository.stop());
  });
  return repository;
}

@Riverpod(keepAlive: true)
bool ttsAutoBootstrap(Ref ref) {
  return true;
}

@Riverpod(keepAlive: true)
class TtsController extends _$TtsController {
  late final TtsRepository _ttsRepository;
  late final AppErrorAdvisor _errorAdvisor;

  @override
  TtsState build() {
    _ttsRepository = ref.read(ttsRepositoryProvider);
    _errorAdvisor = ref.read(appErrorAdvisorProvider);
    if (ref.read(ttsAutoBootstrapProvider)) {
      unawaited(
        Future<void>.microtask(() async {
          if (ref.mounted) {
            await initialize();
          }
        }),
      );
    }
    return TtsState.initial();
  }

  Future<void> initialize() async {
    if (state.engine.status.isInitializing || state.engine.isInitialized) {
      return;
    }
    await _runWithStatus(
      status: const TtsStatus.initializing(),
      onError: AppErrorCode.ttsInitFailed,
      operation: () async {
        await _ttsRepository.init();
        state = state.copyWith(
          engine: state.engine.copyWith(isInitialized: true),
        );
        await _loadVoicesInternal();
      },
    );
  }

  Future<void> loadVoices() async {
    if (state.engine.status.isLoadingVoices ||
        state.engine.status.isInitializing ||
        state.engine.status.isReading) {
      return;
    }
    await _runWithStatus(
      status: const TtsStatus.loadingVoices(),
      onError: AppErrorCode.ttsLoadVoicesFailed,
      operation: _loadVoicesInternal,
    );
  }

  Future<void> readText() async {
    if (state.engine.status.isReading ||
        state.engine.status.isInitializing ||
        state.engine.status.isLoadingVoices) {
      return;
    }
    final String message = StringUtils.normalize(state.inputText);
    if (message.isEmpty) {
      return;
    }

    await _runWithStatus(
      status: const TtsStatus.reading(),
      onError: AppErrorCode.ttsReadFailed,
      operation: () async {
        await _ttsRepository.speak(
          message,
          mode: state.config.languageMode,
          settings: TtsVoiceSettings(
            speechRate: state.config.speechRate,
            pitch: state.config.pitch,
            volume: state.config.volume,
          ),
          voice: _selectedVoice,
        );
      },
    );
  }

  Future<void> stopReading() async {
    await _runWithStatus(
      status: const TtsStatus.reading(),
      onError: AppErrorCode.ttsStopFailed,
      operation: _ttsRepository.stop,
    );
  }

  void setInputText(String value) {
    state = state.copyWith(inputText: value);
  }

  void setLanguageMode(TtsLanguageMode mode) {
    state = state.copyWith(config: state.config.copyWith(languageMode: mode));
  }

  void setSample(TtsSampleText sample) {
    state = state.copyWith(
      inputText: sample.text,
      config: state.config.copyWith(languageMode: sample.mode),
    );
  }

  void setSpeechRate(double value) {
    state = state.copyWith(config: state.config.copyWith(speechRate: value));
  }

  void setPitch(double value) {
    state = state.copyWith(config: state.config.copyWith(pitch: value));
  }

  void setVolume(double value) {
    state = state.copyWith(config: state.config.copyWith(volume: value));
  }

  void selectVoice(String? voiceId) {
    state = state.copyWith(
      config: state.config.copyWith(selectedVoiceId: voiceId),
    );
  }

  TtsVoiceOption? get _selectedVoice {
    for (final TtsVoiceOption voice in state.engine.voices) {
      if (voice.id == state.config.selectedVoiceId) {
        return voice;
      }
    }
    return null;
  }

  Future<void> _loadVoicesInternal() async {
    final List<TtsVoiceOption> voices = await _ttsRepository.getAvailableVoices(
      localePrefix: TtsConstants.koreanLocalePrefix,
    );
    final bool hasSelected =
        state.config.selectedVoiceId != null &&
        voices.any((voice) => voice.id == state.config.selectedVoiceId);
    state = state.copyWith(
      engine: state.engine.copyWith(voices: voices),
      config: state.config.copyWith(
        selectedVoiceId: hasSelected ? state.config.selectedVoiceId : null,
      ),
    );
  }

  Future<void> _runWithStatus({
    required TtsStatus status,
    required Future<void> Function() operation,
    AppErrorCode onError = AppErrorCode.unknown,
  }) async {
    state = state.copyWith(engine: state.engine.copyWith(status: status));
    try {
      await operation();
    } catch (error) {
      _errorAdvisor.handle(error, fallback: onError);
    } finally {
      state = state.copyWith(
        engine: state.engine.copyWith(status: const TtsStatus.idle()),
      );
    }
  }
}

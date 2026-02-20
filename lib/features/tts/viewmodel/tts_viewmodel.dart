import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_error_mapper.dart';
import '../../../core/error/error_code.dart';
import '../../../core/utils/string_utils.dart';
import '../model/tts_constants.dart';
import '../model/tts_models.dart';
import '../repository/tts_repository.dart';
import '../repository/tts_service.dart';
import 'tts_state.dart';

part 'tts_viewmodel.g.dart';

@Riverpod(keepAlive: true)
TtsRepository ttsRepository(Ref ref) {
  final TtsRepository repository = TtsService();
  ref.onDispose(() {
    unawaited(repository.dispose());
  });
  return repository;
}

@Riverpod(keepAlive: true)
bool ttsAutoBootstrap(Ref ref) {
  return true;
}

@Riverpod(keepAlive: true)
class TtsController extends _$TtsController {
  static const Duration _livePreviewDebounceDelay = Duration(
    milliseconds: TtsConstants.livePreviewDebounceMilliseconds,
  );

  Timer? _livePreviewDebounceTimer;

  TtsRepository get _ttsRepository {
    return ref.read(ttsRepositoryProvider);
  }

  AppErrorAdvisor get _errorAdvisor {
    return ref.read(appErrorAdvisorProvider);
  }

  @override
  TtsState build() {
    ref.onDispose(() {
      _livePreviewDebounceTimer?.cancel();
    });
    if (ref.read(ttsAutoBootstrapProvider)) {
      unawaited(
        Future<void>.microtask(() async {
          if (!ref.mounted) {
            return;
          }
          await initialize();
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
        await _loadVoicesInternal(
          localePrefix: TtsConstants.koreanLocalePrefix,
        );
      },
    );
  }

  Future<void> loadVoices({String? localePrefix}) async {
    if (state.engine.status.isLoadingVoices ||
        state.engine.status.isInitializing ||
        state.engine.status.isReading) {
      return;
    }
    await _runWithStatus(
      status: const TtsStatus.loadingVoices(),
      onError: AppErrorCode.ttsLoadVoicesFailed,
      operation: () async {
        await _loadVoicesInternal(localePrefix: localePrefix);
      },
    );
  }

  Future<void> speakText(String text, {bool forceRestart = false}) async {
    if (state.engine.status.isReading && !forceRestart) {
      return;
    }
    if (state.engine.status.isInitializing ||
        state.engine.status.isLoadingVoices) {
      return;
    }
    final String message = StringUtils.normalize(text);
    if (message.isEmpty) {
      return;
    }
    await _speakMessage(message);
  }

  Future<void> previewWithConfig({
    required String previewText,
    required String? voiceId,
    required double speechRate,
    required double pitch,
    required double volume,
  }) async {
    final String message = StringUtils.normalize(previewText);
    if (message.isEmpty) {
      return;
    }
    applyVoiceSettings(
      voiceId: voiceId,
      speechRate: speechRate,
      pitch: pitch,
      volume: volume,
      clearVoiceId: voiceId == null,
    );
    await initialize();
    if (!ref.mounted) {
      return;
    }
    await _speakMessage(message);
  }

  void queueLivePreview({
    required String previewText,
    required String? voiceId,
    required double speechRate,
    required double pitch,
    required double volume,
    required bool isPreviewActive,
  }) {
    final String message = StringUtils.normalize(previewText);
    if (message.isEmpty) {
      return;
    }
    applyVoiceSettings(
      voiceId: voiceId,
      speechRate: speechRate,
      pitch: pitch,
      volume: volume,
      clearVoiceId: voiceId == null,
    );
    if (!isPreviewActive) {
      return;
    }
    _livePreviewDebounceTimer?.cancel();
    _livePreviewDebounceTimer = Timer(_livePreviewDebounceDelay, () {
      unawaited(_runDebouncedLivePreview(message));
    });
  }

  Future<void> stopReading() async {
    await _runWithStatus(
      status: const TtsStatus.reading(),
      onError: AppErrorCode.ttsStopFailed,
      operation: _ttsRepository.stop,
    );
  }

  void setLanguageMode(TtsLanguageMode mode) {
    state = state.copyWith(config: state.config.copyWith(languageMode: mode));
  }

  void applyVoiceSettings({
    String? voiceId,
    bool clearVoiceId = false,
    double? speechRate,
    double? pitch,
    double? volume,
  }) {
    final String? nextVoiceId = clearVoiceId
        ? null
        : (voiceId ?? state.config.selectedVoiceId);
    state = state.copyWith(
      config: state.config.copyWith(
        selectedVoiceId: nextVoiceId,
        speechRate: speechRate ?? state.config.speechRate,
        pitch: pitch ?? state.config.pitch,
        volume: volume ?? state.config.volume,
      ),
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

  Future<void> _loadVoicesInternal({String? localePrefix}) async {
    final List<TtsVoiceOption> voices = await _ttsRepository.getAvailableVoices(
      localePrefix: localePrefix,
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

  Future<void> _runDebouncedLivePreview(String message) async {
    if (!ref.mounted) {
      return;
    }
    await _speakMessage(message);
  }

  Future<void> _speakMessage(
    String message, {
    bool stopBeforeSpeak = true,
  }) async {
    if (!state.engine.isInitialized) {
      await initialize();
    }
    if (state.engine.status.isInitializing ||
        state.engine.status.isLoadingVoices) {
      return;
    }
    await _runWithStatus(
      status: const TtsStatus.reading(),
      onError: AppErrorCode.ttsReadFailed,
      operation: () async {
        if (stopBeforeSpeak) {
          await _ttsRepository.stop();
        }
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

  Future<void> _runWithStatus({
    required TtsStatus status,
    required Future<void> Function() operation,
    AppErrorCode onError = AppErrorCode.unknown,
  }) async {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(engine: state.engine.copyWith(status: status));
    try {
      await operation();
    } catch (error) {
      if (ref.mounted) {
        _errorAdvisor.handle(error, fallback: onError);
      }
    } finally {
      if (ref.mounted) {
        state = state.copyWith(
          engine: state.engine.copyWith(status: const TtsStatus.idle()),
        );
      }
    }
  }
}

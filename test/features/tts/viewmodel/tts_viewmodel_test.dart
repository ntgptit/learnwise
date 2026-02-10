import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/error/app_error_bus.dart';
import 'package:learnwise/core/error/error_code.dart';
import 'package:learnwise/features/tts/model/tts_models.dart';
import 'package:learnwise/features/tts/model/tts_sample_text.dart';
import 'package:learnwise/features/tts/repository/tts_repository.dart';
import 'package:learnwise/features/tts/viewmodel/tts_state.dart';
import 'package:learnwise/features/tts/viewmodel/tts_viewmodel.dart';

class FakeTtsRepository implements TtsRepository {
  bool failInit = false;
  bool failLoadVoices = false;
  bool failSpeak = false;
  bool failStop = false;

  int initCalls = 0;
  int speakCalls = 0;
  int stopCalls = 0;
  int loadVoicesCalls = 0;

  String? lastSpokenText;
  TtsLanguageMode? lastMode;
  TtsVoiceSettings? lastSettings;
  TtsVoiceOption? lastVoice;

  List<TtsVoiceOption> voicesResult = <TtsVoiceOption>[];

  @override
  Future<void> init({
    TtsVoiceSettings settings = const TtsVoiceSettings(),
  }) async {
    initCalls++;
    if (failInit) {
      throw Exception('init failed');
    }
  }

  @override
  Future<void> speak(
    String text, {
    TtsLanguageMode mode = TtsLanguageMode.auto,
    TtsVoiceSettings settings = const TtsVoiceSettings(),
    TtsVoiceOption? voice,
  }) async {
    speakCalls++;
    lastSpokenText = text;
    lastMode = mode;
    lastSettings = settings;
    lastVoice = voice;
    if (failSpeak) {
      throw Exception('speak failed');
    }
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    if (failStop) {
      throw Exception('stop failed');
    }
  }

  @override
  Future<List<TtsVoiceOption>> getAvailableVoices({
    String? localePrefix,
  }) async {
    loadVoicesCalls++;
    if (failLoadVoices) {
      throw Exception('load voices failed');
    }
    return voicesResult;
  }
}

void main() {
  group('TtsController', () {
    test('initialize sets initialized and loads voices', () async {
      final FakeTtsRepository fakeRepo = FakeTtsRepository()
        ..voicesResult = <TtsVoiceOption>[
          const TtsVoiceOption(
            id: 'ko-1',
            name: 'Ko Voice',
            locale: 'ko-KR',
            params: <String, String>{'name': 'Ko Voice', 'locale': 'ko-KR'},
          ),
        ];
      final ProviderContainer container = ProviderContainer(
        overrides: [
          ttsRepositoryProvider.overrideWithValue(fakeRepo),
          ttsAutoBootstrapProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      await container.read(ttsControllerProvider.notifier).initialize();
      final TtsState state = container.read(ttsControllerProvider);

      expect(fakeRepo.initCalls, 1);
      expect(fakeRepo.loadVoicesCalls, 1);
      expect(state.isInitialized, true);
      expect(state.voices.length, 1);
      expect(container.read(appErrorBusProvider), isNull);
    });

    test('initialize failure emits notice event', () async {
      final FakeTtsRepository fakeRepo = FakeTtsRepository()..failInit = true;
      final ProviderContainer container = ProviderContainer(
        overrides: [
          ttsRepositoryProvider.overrideWithValue(fakeRepo),
          ttsAutoBootstrapProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      await container.read(ttsControllerProvider.notifier).initialize();
      final AppErrorEvent? notice = container.read(appErrorBusProvider);

      expect(notice, isNotNull);
      expect(notice!.code, AppErrorCode.ttsInitFailed);
    });

    test('readText uses current state and calls speak', () async {
      final FakeTtsRepository fakeRepo = FakeTtsRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          ttsRepositoryProvider.overrideWithValue(fakeRepo),
          ttsAutoBootstrapProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      final TtsController controller = container.read(
        ttsControllerProvider.notifier,
      );
      controller.setInputText('hello');
      controller.setLanguageMode(TtsLanguageMode.english);
      controller.setSpeechRate(0.5);
      controller.setPitch(1.1);
      controller.setVolume(0.9);

      await controller.readText();

      expect(fakeRepo.speakCalls, 1);
      expect(fakeRepo.lastSpokenText, 'hello');
      expect(fakeRepo.lastMode, TtsLanguageMode.english);
      expect(fakeRepo.lastSettings, isNotNull);
      expect(fakeRepo.lastSettings!.speechRate, 0.5);
      expect(fakeRepo.lastSettings!.pitch, 1.1);
      expect(fakeRepo.lastSettings!.volume, 0.9);
    });

    test('app error bus consumes only matching event id', () async {
      final FakeTtsRepository fakeRepo = FakeTtsRepository()
        ..failLoadVoices = true;
      final ProviderContainer container = ProviderContainer(
        overrides: [
          ttsRepositoryProvider.overrideWithValue(fakeRepo),
          ttsAutoBootstrapProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      final TtsController controller = container.read(
        ttsControllerProvider.notifier,
      );
      await controller.loadVoices();
      final AppErrorEvent? firstNotice = container.read(appErrorBusProvider);
      expect(firstNotice, isNotNull);
      expect(firstNotice!.code, AppErrorCode.ttsLoadVoicesFailed);

      container.read(appErrorBusProvider.notifier).consume(firstNotice.id + 1);
      expect(container.read(appErrorBusProvider), isNotNull);

      container.read(appErrorBusProvider.notifier).consume(firstNotice.id);
      expect(container.read(appErrorBusProvider), isNull);
    });

    test('setSample updates input text and mode', () {
      final FakeTtsRepository fakeRepo = FakeTtsRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          ttsRepositoryProvider.overrideWithValue(fakeRepo),
          ttsAutoBootstrapProvider.overrideWithValue(false),
        ],
      );
      addTearDown(container.dispose);

      final TtsController controller = container.read(
        ttsControllerProvider.notifier,
      );
      controller.setSample(
        const TtsSampleText(
          label: 'EN',
          text: 'sample text',
          mode: TtsLanguageMode.english,
        ),
      );

      final TtsState state = container.read(ttsControllerProvider);
      expect(state.inputText, 'sample text');
      expect(state.languageMode, TtsLanguageMode.english);
    });
  });
}

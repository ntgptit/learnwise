import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/error/app_error_bus.dart';
import 'package:learnwise/core/error/error_code.dart';
import 'package:learnwise/features/tts/model/tts_models.dart';
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
  Completer<void>? speakBlocker;

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
    final Completer<void>? blocker = speakBlocker;
    if (blocker == null) {
      return;
    }
    if (blocker.isCompleted) {
      return;
    }
    await blocker.future;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    if (failStop) {
      throw Exception('stop failed');
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
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

Future<void> _waitUntil({
  required bool Function() predicate,
  int maxTries = 50,
  Duration delay = const Duration(milliseconds: 10),
}) async {
  for (int index = 0; index < maxTries; index += 1) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(delay);
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

    test('speakText uses current config and calls speak', () async {
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
      controller.setLanguageMode(TtsLanguageMode.english);
      controller.applyVoiceSettings(speechRate: 0.5, pitch: 1.1, volume: 0.9);

      await controller.speakText('hello');

      expect(fakeRepo.speakCalls, 1);
      expect(fakeRepo.lastSpokenText, 'hello');
      expect(fakeRepo.lastMode, TtsLanguageMode.english);
      expect(fakeRepo.lastSettings, isNotNull);
      expect(fakeRepo.lastSettings!.speechRate, 0.5);
      expect(fakeRepo.lastSettings!.pitch, 1.1);
      expect(fakeRepo.lastSettings!.volume, 0.9);
    });

    test('speakText forceRestart can replay while reading', () async {
      final FakeTtsRepository fakeRepo = FakeTtsRepository()
        ..speakBlocker = Completer<void>();
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
      final Future<void> firstRead = controller.speakText('hello');
      await _waitUntil(predicate: () => fakeRepo.speakCalls == 1);
      expect(fakeRepo.speakCalls, 1);

      await controller.speakText('hello');
      expect(fakeRepo.speakCalls, 1);

      final Future<void> replayRead = controller.speakText(
        'hello',
        forceRestart: true,
      );
      await _waitUntil(predicate: () => fakeRepo.speakCalls == 2);
      expect(fakeRepo.speakCalls, 2);

      fakeRepo.speakBlocker!.complete();
      await firstRead;
      await replayRead;
    });

    test('speakText skips when input is blank', () async {
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
      await controller.speakText('   ');

      expect(fakeRepo.speakCalls, 0);
    });

    test(
      'previewWithConfig applies settings and speaks preview text',
      () async {
        // test-guard: covers TtsController.previewWithConfig
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
        await controller.previewWithConfig(
          previewText: 'preview text',
          voiceId: null,
          speechRate: 0.7,
          pitch: 1.2,
          volume: 0.8,
        );

        expect(fakeRepo.speakCalls, 1);
        expect(fakeRepo.lastSpokenText, 'preview text');
        expect(fakeRepo.lastSettings, isNotNull);
        expect(fakeRepo.lastSettings!.speechRate, 0.7);
        expect(fakeRepo.lastSettings!.pitch, 1.2);
        expect(fakeRepo.lastSettings!.volume, 0.8);
      },
    );

    test('queueLivePreview triggers debounced preview while active', () async {
      // test-guard: covers TtsController.queueLivePreview
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
      controller.queueLivePreview(
        previewText: 'queued preview',
        voiceId: null,
        speechRate: 0.6,
        pitch: 1.1,
        volume: 0.9,
        isPreviewActive: true,
      );

      await _waitUntil(
        predicate: () => fakeRepo.speakCalls == 1,
        maxTries: 120,
      );
      expect(fakeRepo.speakCalls, 1);
      expect(fakeRepo.lastSpokenText, 'queued preview');
    });

    test(
      'speakText sends selected voice when selectedVoiceId matches',
      () async {
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

        final TtsController controller = container.read(
          ttsControllerProvider.notifier,
        );
        await controller.loadVoices();
        controller.applyVoiceSettings(voiceId: 'ko-1');
        await controller.speakText('hello');

        expect(fakeRepo.lastVoice, isNotNull);
        expect(fakeRepo.lastVoice!.id, 'ko-1');
      },
    );

    test(
      'loadVoices clears selected voice when selected voice is missing',
      () async {
        final FakeTtsRepository fakeRepo = FakeTtsRepository()
          ..voicesResult = <TtsVoiceOption>[
            const TtsVoiceOption(
              id: 'ko-2',
              name: 'Ko Voice 2',
              locale: 'ko-KR',
              params: <String, String>{'name': 'Ko Voice 2', 'locale': 'ko-KR'},
            ),
          ];
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
        controller.applyVoiceSettings(voiceId: 'ko-1');

        await controller.loadVoices();

        final TtsState state = container.read(ttsControllerProvider);
        expect(state.config.selectedVoiceId, isNull);
      },
    );

    test('stopReading forwards stop call to repository', () async {
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
      await controller.stopReading();

      expect(fakeRepo.stopCalls, 1);
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

    test('setLanguageMode updates language mode only', () {
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
      controller.setLanguageMode(TtsLanguageMode.english);

      final TtsState state = container.read(ttsControllerProvider);
      expect(state.languageMode, TtsLanguageMode.english);
    });
  });
}

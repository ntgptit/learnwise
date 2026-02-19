import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profile/model/profile_models.dart';
import '../../profile/viewmodel/profile_viewmodel.dart';
import '../model/deck_models.dart';
import '../repository/deck_repository.dart';
import '../repository/deck_repository_provider.dart';

part 'deck_audio_settings_viewmodel.g.dart';

@Riverpod(keepAlive: true)
Future<DeckAudioSettings?> deckAudioSettings(Ref ref, int deckId) async {
  if (deckId <= 0) {
    return null;
  }
  final DeckRepository repository = ref.read(deckRepositoryProvider);
  return repository.getDeckAudioSettings(deckId: deckId);
}

@Riverpod(keepAlive: true)
UserStudySettings effectiveStudySettingsForDeck(Ref ref, int deckId) {
  final UserStudySettings globalSettings = ref.watch(userStudySettingsProvider);
  if (deckId <= 0) {
    return globalSettings;
  }
  final AsyncValue<DeckAudioSettings?> deckSettingsState = ref.watch(
    deckAudioSettingsProvider(deckId),
  );
  return deckSettingsState.when(
    data: (deckSettings) {
      if (deckSettings == null) {
        return globalSettings;
      }
      return globalSettings.copyWith(
        studyAutoPlayAudio: deckSettings.autoPlayAudio,
        studyCardsPerSession: deckSettings.cardsPerSession,
        ttsVoiceId: deckSettings.ttsVoiceId,
        clearTtsVoiceId: deckSettings.ttsVoiceId == null,
        ttsSpeechRate: deckSettings.ttsSpeechRate,
        ttsPitch: deckSettings.ttsPitch,
        ttsVolume: deckSettings.ttsVolume,
      );
    },
    loading: () => globalSettings,
    error: (error, stackTrace) => globalSettings,
  );
}

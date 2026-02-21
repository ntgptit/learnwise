import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/dashboard/model/dashboard_constants.dart';
import 'package:learnwise/features/decks/model/deck_constants.dart';
import 'package:learnwise/features/flashcards/model/flashcard_constants.dart';
import 'package:learnwise/features/flashcards/model/language_models.dart';
import 'package:learnwise/features/profile/model/profile_constants.dart';
import 'package:learnwise/features/study/model/study_constants.dart';
import 'package:learnwise/features/tts/model/tts_constants.dart';

void main() {
  test('feature constants remain accessible', () {
    expect(DeckConstants.defaultPage, 0);
    expect(FlashcardConstants.defaultPage, 0);
    expect(StudyConstants.defaultIndex, 0);
    expect(ProfileConstants.profileNavIndex, 2);
    expect(TtsConstants.defaultSpeechRate, 0.48);
    expect(DashboardConstants.defaultDisplayName, 'Learner');
  });

  test('language item supports json roundtrip', () {
    const LanguageItem item = LanguageItem(
      code: 'en',
      name: 'English',
      nativeName: 'English',
    );
    final Map<String, dynamic> json = item.toJson();
    final LanguageItem parsed = LanguageItem.fromJson(json);
    expect(parsed, item);
  });
}

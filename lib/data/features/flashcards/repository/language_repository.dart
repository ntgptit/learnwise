import 'package:learnwise/domain/features/flashcards/model/language_models.dart';

abstract class LanguageRepository {
  Future<List<LanguageItem>> fetchLanguages();
}

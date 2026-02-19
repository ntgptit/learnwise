import '../model/language_models.dart';

abstract class LanguageRepository {
  Future<List<LanguageItem>> fetchLanguages();
}

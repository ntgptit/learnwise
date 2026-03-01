import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:learnwise/domain/features/flashcards/model/language_models.dart';
import 'package:learnwise/data/features/flashcards/repository/language_repository_provider.dart';

part 'language_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class LanguagesController extends _$LanguagesController {
  @override
  Future<List<LanguageItem>> build() async {
    return ref.read(languageRepositoryProvider).fetchLanguages();
  }
}

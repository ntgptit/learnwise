import 'package:reactive_forms/reactive_forms.dart';

import '../../../../core/utils/string_utils.dart';
import '../../model/flashcard_constants.dart';
import '../../model/flashcard_models.dart';

class FlashcardFormSchema {
  const FlashcardFormSchema._();

  static const String frontTextControlKey = 'frontText';
  static const String backTextControlKey = 'backText';
  static const String frontLangCodeControlKey = 'frontLangCode';
  static const String backLangCodeControlKey = 'backLangCode';
  static const String nonWhitespacePattern = r'^.*\S.*$';

  static FormGroup build({required FlashcardItem? initialFlashcard}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      frontTextControlKey: FormControl<String>(
        value: initialFlashcard?.frontText ?? '',
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.pattern(RegExp(nonWhitespacePattern)),
          Validators.minLength(FlashcardConstants.frontTextMinLength),
          Validators.maxLength(FlashcardConstants.frontTextMaxLength),
        ],
      ),
      backTextControlKey: FormControl<String>(
        value: initialFlashcard?.backText ?? '',
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.pattern(RegExp(nonWhitespacePattern)),
          Validators.minLength(FlashcardConstants.backTextMinLength),
          Validators.maxLength(FlashcardConstants.backTextMaxLength),
        ],
      ),
      frontLangCodeControlKey: FormControl<String?>(
        value: initialFlashcard?.frontLangCode,
      ),
      backLangCodeControlKey: FormControl<String?>(
        value: initialFlashcard?.backLangCode,
      ),
    });
  }

  static FormControl<String> resolveFrontTextControl(FormGroup form) {
    final AbstractControl<Object?> control = form.control(frontTextControlKey);
    return control as FormControl<String>;
  }

  static FormControl<String> resolveBackTextControl(FormGroup form) {
    final AbstractControl<Object?> control = form.control(backTextControlKey);
    return control as FormControl<String>;
  }

  static FormControl<String?> resolveFrontLangCodeControl(FormGroup form) {
    final AbstractControl<Object?> control = form.control(
      frontLangCodeControlKey,
    );
    return control as FormControl<String?>;
  }

  static FormControl<String?> resolveBackLangCodeControl(FormGroup form) {
    final AbstractControl<Object?> control = form.control(
      backLangCodeControlKey,
    );
    return control as FormControl<String?>;
  }

  static FlashcardUpsertInput toUpsertInput({required FormGroup form}) {
    final FormControl<String> frontTextControl = resolveFrontTextControl(form);
    final FormControl<String> backTextControl = resolveBackTextControl(form);
    final FormControl<String?> frontLangControl = resolveFrontLangCodeControl(
      form,
    );
    final FormControl<String?> backLangControl = resolveBackLangCodeControl(
      form,
    );
    return FlashcardUpsertInput(
      frontText: StringUtils.normalize(frontTextControl.value ?? ''),
      backText: StringUtils.normalize(backTextControl.value ?? ''),
      frontLangCode: frontLangControl.value,
      backLangCode: backLangControl.value,
    );
  }
}

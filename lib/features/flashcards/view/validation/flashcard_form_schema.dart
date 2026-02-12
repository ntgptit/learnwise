import 'package:reactive_forms/reactive_forms.dart';

import '../../model/flashcard_constants.dart';
import '../../model/flashcard_models.dart';

class FlashcardFormSchema {
  const FlashcardFormSchema._();

  static const String frontTextControlKey = 'frontText';
  static const String backTextControlKey = 'backText';
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

  static FlashcardUpsertInput toUpsertInput({required FormGroup form}) {
    final FormControl<String> frontTextControl = resolveFrontTextControl(form);
    final FormControl<String> backTextControl = resolveBackTextControl(form);
    return FlashcardUpsertInput(
      frontText: _normalize(frontTextControl.value),
      backText: _normalize(backTextControl.value),
    );
  }

  static String _normalize(Object? value) {
    if (value is! String) {
      return '';
    }
    return value.trim();
  }
}

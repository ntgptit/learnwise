import 'package:reactive_forms/reactive_forms.dart';

import '../../../../core/utils/string_utils.dart';
import '../../model/deck_constants.dart';
import '../../model/deck_models.dart';

class DeckFormSchema {
  const DeckFormSchema._();

  static const String nameControlKey = 'name';
  static const String descriptionControlKey = 'description';
  static const String backendNameErrorKey = 'backend_name';
  static const String nonWhitespacePattern = r'^.*\S.*$';

  static FormGroup build({required DeckItem? initialDeck}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      nameControlKey: FormControl<String>(
        value: initialDeck?.name ?? '',
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.pattern(RegExp(nonWhitespacePattern)),
          Validators.minLength(DeckConstants.nameMinLength),
          Validators.maxLength(DeckConstants.nameMaxLength),
        ],
      ),
      descriptionControlKey: FormControl<String>(
        value: initialDeck?.description ?? '',
        validators: <Validator<dynamic>>[
          Validators.maxLength(DeckConstants.descriptionMaxLength),
        ],
      ),
    });
  }

  static FormControl<String> resolveNameControl(FormGroup form) {
    final AbstractControl<Object?> control = form.control(nameControlKey);
    return control as FormControl<String>;
  }

  static FormControl<String> resolveDescriptionControl(FormGroup form) {
    final AbstractControl<Object?> control = form.control(
      descriptionControlKey,
    );
    return control as FormControl<String>;
  }

  static DeckUpsertInput toUpsertInput({required FormGroup form}) {
    final FormControl<String> nameControl = resolveNameControl(form);
    final FormControl<String> descriptionControl = resolveDescriptionControl(
      form,
    );
    return DeckUpsertInput(
      name: _normalize(nameControl.value),
      description: _normalize(descriptionControl.value),
    );
  }

  static void setBackendNameError({
    required FormGroup form,
    required String message,
  }) {
    final FormControl<String> nameControl = resolveNameControl(form);
    nameControl.setErrors(<String, Object>{backendNameErrorKey: message});
    nameControl.markAsTouched();
  }

  static void clearBackendNameError(FormGroup form) {
    final FormControl<String> nameControl = resolveNameControl(form);
    final bool hasBackendError = nameControl.hasError(backendNameErrorKey);
    if (!hasBackendError) {
      return;
    }
    nameControl.removeError(backendNameErrorKey);
  }

  static String _normalize(Object? value) {
    if (value is! String) {
      return '';
    }
    return StringUtils.normalize(value);
  }
}

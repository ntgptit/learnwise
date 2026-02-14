import 'package:reactive_forms/reactive_forms.dart';

import '../../../../core/utils/string_utils.dart';
import '../../model/folder_constants.dart';
import '../../model/folder_models.dart';

class FolderFormSchema {
  const FolderFormSchema._();

  static const String nameControlKey = 'name';
  static const String descriptionControlKey = 'description';
  static const String backendNameErrorKey = 'backend_name';
  static const String nonWhitespacePattern = r'^.*\S.*$';

  static FormGroup build({required FolderItem? initialFolder}) {
    return FormGroup(<String, AbstractControl<Object?>>{
      nameControlKey: FormControl<String>(
        value: initialFolder?.name ?? '',
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.pattern(RegExp(nonWhitespacePattern)),
          Validators.minLength(FolderConstants.nameMinLength),
          Validators.maxLength(FolderConstants.nameMaxLength),
        ],
      ),
      descriptionControlKey: FormControl<String>(
        value: initialFolder?.description ?? '',
        validators: <Validator<dynamic>>[
          Validators.maxLength(FolderConstants.descriptionMaxLength),
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

  static FolderUpsertInput toUpsertInput({
    required FormGroup form,
    required String colorHex,
    required int? parentFolderId,
  }) {
    final FormControl<String> nameControl = resolveNameControl(form);
    final FormControl<String> descriptionControl = resolveDescriptionControl(
      form,
    );
    final String name = StringUtils.normalize(nameControl.value ?? '');
    final String description = StringUtils.normalize(
      descriptionControl.value ?? '',
    );
    return FolderUpsertInput(
      name: name,
      description: description,
      colorHex: colorHex,
      parentFolderId: parentFolderId,
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
}

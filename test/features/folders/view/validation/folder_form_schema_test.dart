import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/folders/model/folder_constants.dart';
import 'package:learnwise/features/folders/view/validation/folder_form_schema.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  group('FolderFormSchema', () {
    test('rejects whitespace-only folder name', () {
      final FormGroup form = FolderFormSchema.build(initialFolder: null);
      final FormControl<String> nameControl =
          FolderFormSchema.resolveNameControl(form);

      nameControl.value = '   ';

      expect(form.valid, false);
      expect(nameControl.hasError(ValidationMessage.pattern), true);
    });

    test('returns trimmed input for submit payload', () {
      final FormGroup form = FolderFormSchema.build(initialFolder: null);
      final FormControl<String> nameControl =
          FolderFormSchema.resolveNameControl(form);
      final FormControl<String> descriptionControl =
          FolderFormSchema.resolveDescriptionControl(form);

      nameControl.value = '  Algebra  ';
      descriptionControl.value = '  Week 1  ';

      final input = FolderFormSchema.toUpsertInput(
        form: form,
        colorHex: FolderConstants.defaultColorHex,
        parentFolderId: 9,
      );

      expect(input.name, 'Algebra');
      expect(input.description, 'Week 1');
      expect(input.colorHex, FolderConstants.defaultColorHex);
      expect(input.parentFolderId, 9);
    });

    test('supports backend name error set and clear', () {
      final FormGroup form = FolderFormSchema.build(initialFolder: null);

      FolderFormSchema.setBackendNameError(
        form: form,
        message: 'Duplicated name',
      );
      final FormControl<String> nameControl =
          FolderFormSchema.resolveNameControl(form);
      expect(nameControl.hasError(FolderFormSchema.backendNameErrorKey), true);

      FolderFormSchema.clearBackendNameError(form);
      expect(nameControl.hasError(FolderFormSchema.backendNameErrorKey), false);
    });

    test('applies description max length rule', () {
      final FormGroup form = FolderFormSchema.build(initialFolder: null);
      final FormControl<String> descriptionControl =
          FolderFormSchema.resolveDescriptionControl(form);
      final String overLimitDescription = List<String>.filled(
        FolderConstants.descriptionMaxLength + 1,
        'a',
      ).join();

      descriptionControl.value = overLimitDescription;

      expect(form.valid, false);
      expect(descriptionControl.hasError(ValidationMessage.maxLength), true);
    });
  });
}

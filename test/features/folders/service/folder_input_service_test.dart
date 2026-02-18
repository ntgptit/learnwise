import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/folders/model/folder_models.dart';
import 'package:learnwise/features/folders/service/folder_input_service.dart';

void main() {
  const FolderInputService service = FolderInputService();

  test('normalize trims values and uppercases colorHex', () {
    const FolderUpsertInput input = FolderUpsertInput(
      name: '  Folder  ',
      description: '  Description  ',
      colorHex: '  #a1b2c3  ',
      parentFolderId: 10,
    );

    final FolderUpsertInput normalized = service.normalize(input);

    expect(normalized.name, 'Folder');
    expect(normalized.description, 'Description');
    expect(normalized.colorHex, '#A1B2C3');
    expect(normalized.parentFolderId, 10);
  });

  test('isValid returns false for invalid colorHex', () {
    const FolderUpsertInput input = FolderUpsertInput(
      name: 'Folder',
      description: '',
      colorHex: 'invalid',
      parentFolderId: null,
    );

    final bool isValid = service.isValid(input);

    expect(isValid, false);
  });
}

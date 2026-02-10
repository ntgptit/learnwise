import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/features/folders/model/folder_models.dart';
import 'package:learnwise/features/folders/view/folder_open_flow.dart';

void main() {
  group('resolveFolderOpenDestination', () {
    test('returns subfolders when folder has child folders', () {
      final FolderItem folder = _buildFolder(
        childFolderCount: 2,
        flashcardCount: 5,
      );

      final FolderOpenDestination destination = resolveFolderOpenDestination(
        folder,
      );

      expect(destination, FolderOpenDestination.subfolders);
    });

    test('returns flashcards when folder has no child and has flashcards', () {
      final FolderItem folder = _buildFolder(
        childFolderCount: 0,
        flashcardCount: 3,
      );

      final FolderOpenDestination destination = resolveFolderOpenDestination(
        folder,
      );

      expect(destination, FolderOpenDestination.flashcards);
    });

    test('returns emptyFolder when folder has no child and no flashcards', () {
      final FolderItem folder = _buildFolder(
        childFolderCount: 0,
        flashcardCount: 0,
      );

      final FolderOpenDestination destination = resolveFolderOpenDestination(
        folder,
      );

      expect(destination, FolderOpenDestination.emptyFolder);
    });
  });
}

FolderItem _buildFolder({
  required int childFolderCount,
  required int flashcardCount,
}) {
  return FolderItem(
    id: 1,
    name: 'Folder',
    description: 'Description',
    colorHex: '#123456',
    parentFolderId: null,
    flashcardCount: flashcardCount,
    childFolderCount: childFolderCount,
    createdBy: 'tester',
    updatedBy: 'tester',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

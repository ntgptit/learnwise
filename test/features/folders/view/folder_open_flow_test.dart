import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/model/audit_metadata.dart';
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

    test('returns decks when folder has no child and has decks', () {
      final FolderItem folder = _buildFolder(
        childFolderCount: 0,
        flashcardCount: 3,
        directDeckCount: 1,
      );

      final FolderOpenDestination destination = resolveFolderOpenDestination(
        folder,
      );

      expect(destination, FolderOpenDestination.decks);
    });

    test('returns emptyFolder when folder has no child and no flashcards', () {
      final FolderItem folder = _buildFolder(
        childFolderCount: 0,
        flashcardCount: 0,
        directDeckCount: 0,
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
  int directDeckCount = 0,
}) {
  return FolderItem(
    id: 1,
    name: 'Folder',
    description: 'Description',
    colorHex: '#123456',
    parentFolderId: null,
    directFlashcardCount: flashcardCount,
    directDeckCount: directDeckCount,
    flashcardCount: flashcardCount,
    childFolderCount: childFolderCount,
    audit: AuditMetadata(
      createdBy: 'tester',
      updatedBy: 'tester',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    ),
  );
}

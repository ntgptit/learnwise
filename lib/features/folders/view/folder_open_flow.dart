import '../model/folder_models.dart';

enum FolderOpenDestination { subfolders, emptyFolder, flashcards }

FolderOpenDestination resolveFolderOpenDestination(FolderItem folder) {
  if (folder.childFolderCount > 0) {
    return FolderOpenDestination.subfolders;
  }
  if (folder.flashcardCount > 0) {
    return FolderOpenDestination.flashcards;
  }
  return FolderOpenDestination.emptyFolder;
}

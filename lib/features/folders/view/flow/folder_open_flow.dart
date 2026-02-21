import '../../model/folder_models.dart';

enum FolderOpenDestination { subfolders, decks, emptyFolder }

FolderOpenDestination resolveFolderOpenDestination(FolderItem folder) {
  if (folder.childFolderCount > 0) {
    return FolderOpenDestination.subfolders;
  }
  if (folder.directDeckCount > 0) {
    return FolderOpenDestination.decks;
  }
  return FolderOpenDestination.emptyFolder;
}

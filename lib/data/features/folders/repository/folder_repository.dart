import 'package:learnwise/domain/features/folders/model/folder_models.dart';

abstract class FolderRepository {
  Future<FolderPageResult> getFolders({
    required FolderListQuery query,
    required int page,
  });

  Future<FolderItem> createFolder(FolderUpsertInput input);

  Future<FolderItem> updateFolder({
    required int folderId,
    required FolderUpsertInput input,
  });

  Future<void> deleteFolder(int folderId);
}

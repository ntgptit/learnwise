import '../../../core/utils/string_utils.dart';
import '../model/folder_constants.dart';
import '../model/folder_models.dart';

class FolderInputService {
  const FolderInputService();

  FolderUpsertInput normalize(FolderUpsertInput input) {
    final String name = StringUtils.normalize(input.name);
    final String description = StringUtils.normalize(input.description);
    final String colorHex = StringUtils.normalize(input.colorHex).toUpperCase();
    return FolderUpsertInput(
      name: name,
      description: description,
      colorHex: colorHex,
      parentFolderId: input.parentFolderId,
    );
  }

  bool isValid(FolderUpsertInput input) {
    if (input.name.length < FolderConstants.nameMinLength) {
      return false;
    }
    if (input.name.length > FolderConstants.nameMaxLength) {
      return false;
    }
    if (input.description.length > FolderConstants.descriptionMaxLength) {
      return false;
    }
    if (!FolderConstants.colorHexPattern.hasMatch(input.colorHex)) {
      return false;
    }
    return true;
  }
}

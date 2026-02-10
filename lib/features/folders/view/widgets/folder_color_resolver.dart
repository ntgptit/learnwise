import 'package:flutter/material.dart';

import '../../model/folder_constants.dart';

Color resolveFolderColor(String colorHex, Color fallbackColor) {
  final String normalizedHex = colorHex.replaceFirst('#', '');

  if (normalizedHex.length == FolderConstants.colorHexRgbLength) {
    final int? value = int.tryParse(
      '${FolderConstants.colorHexDefaultAlpha}$normalizedHex',
      radix: FolderConstants.colorHexRadix,
    );
    if (value != null) {
      return Color(value);
    }
  }

  if (normalizedHex.length == FolderConstants.colorHexArgbLength) {
    final int? value = int.tryParse(
      normalizedHex,
      radix: FolderConstants.colorHexRadix,
    );
    if (value != null) {
      return Color(value);
    }
  }

  return fallbackColor;
}

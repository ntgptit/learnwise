import 'package:flutter/material.dart';

import '../../model/folder_const.dart';

Color resolveFolderColor(String colorHex, Color fallbackColor) {
  final String normalizedHex = colorHex.replaceFirst('#', '');

  if (normalizedHex.length == FolderConst.colorHexRgbLength) {
    final int? value = int.tryParse(
      '${FolderConst.colorHexDefaultAlpha}$normalizedHex',
      radix: FolderConst.colorHexRadix,
    );
    if (value != null) {
      return Color(value);
    }
  }

  if (normalizedHex.length == FolderConst.colorHexArgbLength) {
    final int? value = int.tryParse(
      normalizedHex,
      radix: FolderConst.colorHexRadix,
    );
    if (value != null) {
      return Color(value);
    }
  }

  return fallbackColor;
}

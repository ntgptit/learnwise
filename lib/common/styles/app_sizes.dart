/// Global size foundation for UI constants.
///
/// Rules:
/// - Declaration:
///   - Only define immutable `static const` values.
///   - Use descriptive semantic names (`size16`, `spacingMd`, `radiusLg`).
/// - Value setting:
///   - Spacing/size must follow 4dp grid where applicable.
///   - Legacy aliases may exist for compatibility, but must map to a valid
///     canonical token.
/// - Data flow:
///   - This layer does not receive runtime input.
///   - Widgets/services must only read constants from this layer.
/// - Material 3 constraints:
///   - Prefer M3-friendly touch targets and spacing rhythm.
///   - Radius and spacing should stay consistent with M3 component density.
/// - Value source:
///   - Values are from design baseline and M3 adaptation decisions in project.
///   - Do not introduce ad-hoc values in feature widgets.
class AppSizes {
  const AppSizes._();

  static const double size2 = 2;
  static const double size1 = 1;
  static const double size4 = 4;
  static const double size8 = 8;
  static const double size12 = 12;
  static const double size16 = 16;
  static const double size20 = 20;
  static const double size24 = 24;
  static const double size28 = 28;
  static const double size32 = 32;
  static const double size34 = 34;
  static const double size36 = 36;
  static const double size40 = 40;
  static const double size44 = 44;
  static const double size48 = 48;
  static const double size52 = 52;
  static const double size56 = 56;
  static const double size72 = 72;
  static const double size96 = 96;
  static const double size144 = 144;
  static const double size240 = 240;

  // Compatibility aliases mapped to the nearest 4dp token.
  static const double size6 = size8;
  static const double size10 = size8;
  static const double size14 = size12;
  static const double size18 = size16;
  static const double size22 = size20;
  static const double size26 = size24;

  static const double spacing2Xs = 4;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingXmd = 20;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2Xl = 40;
  static const double spacing3Xl = 48;
  static const double spacing4Xl = 56;
  static const double spacing5Xl = 72;
  static const double spacingHero = 240;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;
}

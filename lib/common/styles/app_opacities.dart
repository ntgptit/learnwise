/// Centralized opacity tokens.
///
/// Rules:
/// - Declaration:
///   - Define only reusable opacity constants as `static const`.
/// - Value setting:
///   - Opacity values must be normalized here and reused by UI.
///   - Screen tokens and widgets must not inline custom alpha values.
/// - Data flow:
///   - Read-only constants; no runtime mutation.
/// - Material 3 constraints:
///   - Prefer subtle alpha layering aligned with M3 surfaces/states.
/// - Value source:
///   - Derived from UI state feedback needs (hover/pressed/disabled/muted).
class AppOpacities {
  const AppOpacities._();

  static const double soft08 = 0.08;
  static const double soft10 = 0.10;
  static const double soft12 = 0.12;
  static const double soft15 = 0.15;
  static const double soft20 = 0.20;
  static const double soft35 = 0.35;
  static const double soft92 = 0.92;
  static const double soft95 = 0.95;
  static const double disabled38 = 0.38;
  static const double muted68 = 0.68;
  static const double muted70 = 0.70;
  static const double muted55 = 0.55;
  static const double muted82 = 0.82;
  static const double outline26 = 0.26;
}

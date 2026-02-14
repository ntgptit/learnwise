import 'package:flutter/animation.dart';

class AppDurations {
  const AppDurations._();

  /// Use for instantaneous state updates where animation is disabled.
  static const Duration instant = Duration.zero;

  /// Use for debounce interactions such as search inputs.
  static const Duration debounceMedium = Duration(milliseconds: 450);

  /// Use for tiny feedback animations (icon swaps, pressed states).
  static const Duration animationSnappy = Duration(milliseconds: 180);

  /// Use for tap/press feedback (card press scale, icon toggles).
  static const Duration animationQuick = Duration(milliseconds: 140);

  /// Use for standard component transitions following Material 3 guidance.
  static const Duration animationStandard = Duration(milliseconds: 200);

  /// Use for quick transitions (buttons, short fades, small shifts).
  static const Duration animationFast = Duration(milliseconds: 300);

  /// Use for standard screen-level component transitions.
  static const Duration animationNormal = Duration(milliseconds: 320);

  /// Use for emphasized transitions with stronger visual attention.
  static const Duration animationEmphasized = Duration(milliseconds: 420);

  /// Use when a success state needs to stay visible a bit longer.
  static const Duration animationHold = Duration(milliseconds: 650);

  /// Use for continuous shimmer/skeleton effects.
  static const Duration shimmerLoop = Duration(milliseconds: 1300);
}

class AppMotionCurves {
  const AppMotionCurves._();

  /// Standard easing curve for component-level state transitions.
  static const Curve standard = Curves.easeInOutCubic;

  /// Linear timing for progress interpolation.
  static const Curve linear = Curves.linear;

  /// Standard decelerating curve for entering content.
  static const Curve decelerate = Curves.easeOut;

  /// Stronger deceleration for larger movement transitions.
  static const Curve decelerateCubic = Curves.easeOutCubic;

  /// Emphasized curve for attention-grabbing transitions.
  static const Curve emphasized = Curves.easeInOutCubic;

  /// Overshoot curve for playful scale entrances.
  static const Curve overshoot = Curves.easeOutBack;
}

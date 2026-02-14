import 'package:flutter/material.dart';

import '../../styles/app_opacities.dart';
import '../../styles/app_sizes.dart';

enum AppCardVariant { outlined, filled, elevated }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppSizes.spacingMd),
    this.margin,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.onTap,
    this.variant = AppCardVariant.outlined,
    this.elevation,
    this.surfaceTintColor,
    this.enablePressedState = true,
    this.pressedOverlayColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final double? elevation;
  final Color? surfaceTintColor;
  final bool enablePressedState;
  final Color? pressedOverlayColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final CardThemeData cardTheme = theme.cardTheme;
    final BorderRadius borderRadius = _resolveBorderRadius(cardTheme);
    final EdgeInsetsGeometry resolvedMargin =
        margin ?? cardTheme.margin ?? EdgeInsets.zero;
    final Widget content = Padding(padding: padding, child: child);
    final BoxBorder resolvedBorder = _resolveBorder(colorScheme);
    final Color resolvedBackgroundColor = _resolveBackgroundColor(
      colorScheme,
      cardTheme,
    );
    final double resolvedElevation = _resolveElevation(cardTheme);
    final Color resolvedSurfaceTintColor = _resolveSurfaceTintColor(
      colorScheme,
      cardTheme,
    );
    final Color resolvedShadowColor =
        cardTheme.shadowColor ?? colorScheme.shadow;

    Widget body = Ink(
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: borderRadius,
        border: resolvedBorder,
      ),
      child: content,
    );

    if (onTap != null) {
      body = InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        overlayColor: _resolveOverlayColor(colorScheme),
        child: body,
      );
    }

    final Widget card = Material(
      color: Colors.transparent,
      elevation: resolvedElevation,
      shadowColor: resolvedShadowColor,
      surfaceTintColor: resolvedSurfaceTintColor,
      borderRadius: borderRadius,
      child: body,
    );

    return Padding(padding: resolvedMargin, child: card);
  }

  BorderRadius _resolveBorderRadius(CardThemeData cardTheme) {
    if (borderRadius != null) {
      return borderRadius!;
    }
    final ShapeBorder? shape = cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      final BorderRadiusGeometry borderRadius = shape.borderRadius;
      if (borderRadius is BorderRadius) {
        return borderRadius;
      }
    }
    return BorderRadius.circular(AppSizes.radiusLg);
  }

  BoxBorder _resolveBorder(ColorScheme colorScheme) {
    if (border != null) {
      return border!;
    }
    if (variant == AppCardVariant.outlined) {
      return Border.all(color: colorScheme.outlineVariant);
    }
    return const Border.fromBorderSide(BorderSide.none);
  }

  Color _resolveBackgroundColor(
    ColorScheme colorScheme,
    CardThemeData cardTheme,
  ) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    if (variant == AppCardVariant.filled) {
      return colorScheme.surfaceContainer;
    }
    if (cardTheme.color != null) {
      return cardTheme.color!;
    }
    return colorScheme.surfaceContainerLow;
  }

  double _resolveElevation(CardThemeData cardTheme) {
    if (variant != AppCardVariant.elevated) {
      return 0;
    }
    if (elevation != null) {
      return elevation!;
    }
    if (cardTheme.elevation != null) {
      return cardTheme.elevation!;
    }
    return AppSizes.size1;
  }

  Color _resolveSurfaceTintColor(
    ColorScheme colorScheme,
    CardThemeData cardTheme,
  ) {
    if (variant != AppCardVariant.elevated) {
      return Colors.transparent;
    }
    if (surfaceTintColor != null) {
      return surfaceTintColor!;
    }
    if (cardTheme.surfaceTintColor != null) {
      return cardTheme.surfaceTintColor!;
    }
    return colorScheme.surfaceTint;
  }

  WidgetStateProperty<Color?>? _resolveOverlayColor(ColorScheme colorScheme) {
    if (!enablePressedState) {
      return null;
    }
    final Color overlay =
        pressedOverlayColor ??
        colorScheme.primary.withValues(alpha: AppOpacities.soft10);
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return overlay;
      }
      if (states.contains(WidgetState.hovered)) {
        return overlay.withValues(alpha: AppOpacities.soft08);
      }
      if (states.contains(WidgetState.focused)) {
        return overlay.withValues(alpha: AppOpacities.soft08);
      }
      return null;
    });
  }
}

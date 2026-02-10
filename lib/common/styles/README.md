# Common Style Constants

This folder is the centralized style-constant area for UI design.

## Naming
- Use descriptive names in `AppSizes`, `AppDurations`, `AppOpacities`, and `AppScreenTokens`.
- Avoid unclear abbreviations for new constants.

## Spacing and Radius
- Use spacing, size, and radius from `AppSizes`.
- Keep widget-level magic numbers out of UI code.

## Screen Tokens
- Use `AppScreenTokens` directly for screen-level layout constants.
- Do not create UI constant files inside feature folders.

## Color Usage
- Prefer `Theme.of(context).colorScheme` for UI colors.
- Keep brand-only colors in `app/theme/colors.dart`.

## Adding New Constants
- Add global constants in this folder.
- Keep feature-only constants inside the feature scope.
- Do not duplicate existing values in multiple places.

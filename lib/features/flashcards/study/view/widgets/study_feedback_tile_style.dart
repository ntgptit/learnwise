import 'package:flutter/material.dart';

import '../../../../../app/theme/semantic_colors.dart';
import '../../../../../common/styles/app_screen_tokens.dart';

Color resolveStudyFeedbackBackgroundColor({
  required ColorScheme colorScheme,
  required bool showSuccessState,
  required bool showErrorState,
  required Color fallbackColor,
}) {
  if (showSuccessState) {
    return colorScheme.successContainer;
  }
  if (showErrorState) {
    return colorScheme.errorContainer;
  }
  return fallbackColor;
}

BoxBorder? resolveStudyFeedbackBorder({
  required ColorScheme colorScheme,
  required bool showSuccessState,
  required bool showErrorState,
}) {
  if (showSuccessState) {
    return Border.all(
      color: colorScheme.onSuccessContainer,
      width: FlashcardStudySessionTokens.matchSuccessBorderWidth,
    );
  }
  if (showErrorState) {
    return Border.all(
      color: colorScheme.onErrorContainer,
      width: FlashcardStudySessionTokens.matchSuccessBorderWidth,
    );
  }
  return null;
}

TextStyle? resolveStudyFeedbackTextStyle({
  required ColorScheme colorScheme,
  required bool showSuccessState,
  required bool showErrorState,
  required TextStyle? fallbackStyle,
}) {
  if (showSuccessState) {
    return fallbackStyle?.copyWith(color: colorScheme.onSuccessContainer);
  }
  if (showErrorState) {
    return fallbackStyle?.copyWith(color: colorScheme.onErrorContainer);
  }
  return fallbackStyle;
}

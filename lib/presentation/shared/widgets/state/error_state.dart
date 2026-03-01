// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import '../buttons/primary_button.dart';

/// A centered error state widget with an icon, message, and optional retry action.
///
/// Displays an error icon with title and optional descriptive message.
/// Optionally includes a retry button when [onRetry] is provided.
///
/// The error state is announced to screen readers via [Semantics] with
/// [liveRegion] enabled for immediate notification.
///
/// Example:
/// ```dart
/// LwErrorState(
///   title: 'Failed to load data',
///   message: 'Please check your internet connection and try again.',
///   retryLabel: 'Retry',
///   onRetry: () => fetchData(),
/// )
/// ```
///
/// See also:
///  * [LwEmptyState], for displaying empty content states
///  * [LwLoadingState], for displaying loading indicators
class LwErrorState extends StatelessWidget {
  const LwErrorState({
    required this.title,
    super.key,
    this.message,
    this.retryLabel,
    this.onRetry,
  }) : assert(
         onRetry == null || retryLabel != null,
         'retryLabel must be provided when onRetry is set.',
       );

  /// The main error title to display.
  final String title;

  /// Optional descriptive message providing more context about the error.
  final String? message;

  /// Label for the retry button.
  ///
  /// Required when [onRetry] is provided.
  final String? retryLabel;

  /// Called when the user taps the retry button.
  ///
  /// If provided, [retryLabel] must also be provided.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final String semanticsLabel = message != null
        ? 'Error: $title. $message'
        : 'Error: $title';
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticsLabel,
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                size: AppSizes.size72,
                color: colorScheme.error,
              ),
              const SizedBox(height: AppSizes.spacingMd),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: AppSizes.spacingXs),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (onRetry != null && retryLabel != null) ...<Widget>[
                const SizedBox(height: AppSizes.spacingMd),
                LwPrimaryButton(
                  label: retryLabel!,
                  expanded: false,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A centered loading indicator with an optional message.
///
/// Displays a circular progress indicator with an optional text message
/// below it. Use this to indicate that content is being loaded or
/// an operation is in progress.
///
/// The loading state is announced to screen readers via [Semantics] with
/// [liveRegion] enabled for immediate notification.
///
/// Example:
/// ```dart
/// LwLoadingState(
///   message: 'Loading your flashcards...',
/// )
/// ```
///
/// See also:
///  * [LwErrorState], for displaying error states
///  * [LwEmptyState], for displaying empty content states
class LwLoadingState extends StatelessWidget {
  const LwLoadingState({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(AppSizes.spacingLg),
  });

  /// Optional message to display below the progress indicator.
  final String? message;

  /// Padding around the loading indicator. Defaults to [AppSizes.spacingLg].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String semanticsLabel = message ?? 'Loading';

    return Semantics(
      label: semanticsLabel,
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              if (message != null) ...<Widget>[
                const SizedBox(height: AppSizes.spacingSm),
                Text(message!, style: textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// A centered empty state widget with an icon, message, and optional action.
///
/// Displays when there is no content to show, such as an empty list or
/// search with no results. Includes a customizable icon, title, optional
/// subtitle, and an optional action widget (e.g., a button to add content).
///
/// The empty state is announced to screen readers via [Semantics] with
/// [liveRegion] enabled for immediate notification.
///
/// Example:
/// ```dart
/// EmptyState(
///   icon: Icons.folder_open_outlined,
///   title: 'No folders yet',
///   subtitle: 'Create your first folder to get started',
///   action: PrimaryButton(
///     label: 'Create Folder',
///     onPressed: () => showCreateFolderDialog(),
///   ),
/// )
/// ```
///
/// See also:
///  * [ErrorState], for displaying error states
///  * [LoadingState], for displaying loading indicators
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title, super.key,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  /// The main title to display.
  final String title;

  /// Optional subtitle providing more context.
  final String? subtitle;

  /// The icon to display above the title. Defaults to [Icons.inbox_rounded].
  final IconData icon;

  /// Optional action widget, typically a button to create content or perform an action.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final String semanticsLabel = subtitle != null
        ? '$title. $subtitle'
        : title;

    return Semantics(
      label: semanticsLabel,
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: AppSizes.spacingLg),
              const SizedBox(height: AppSizes.spacingSm),
              Text(title, textAlign: TextAlign.center),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: AppSizes.spacingXs),
                Text(subtitle!, textAlign: TextAlign.center),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: AppSizes.spacingMd),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

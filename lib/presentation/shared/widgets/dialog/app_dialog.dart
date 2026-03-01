// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

const double _defaultDialogMaxWidth = 560;
const double _dialogContentMaxHeightFactor = 0.6;

enum AppDialogActionLayout { horizontal, vertical }

class LwDialog extends StatelessWidget {
  const LwDialog({
    required this.title,
    required this.content,
    required this.actions,
    super.key,
    this.icon,
    this.maxWidth = _defaultDialogMaxWidth,
    this.actionLayout = AppDialogActionLayout.horizontal,
    this.scrollable = false,
    this.titleTextStyle,
    this.contentPadding,
    this.actionsPadding,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;
  final Widget? icon;
  final double maxWidth;
  final AppDialogActionLayout actionLayout;
  final bool scrollable;
  final TextStyle? titleTextStyle;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final List<Widget> resolvedActions = _resolveActions();
    final Widget resolvedContent = _buildContentWithMaxHeight(context);

    return AlertDialog(
      constraints: BoxConstraints(maxWidth: maxWidth),
      backgroundColor: colorScheme.surfaceContainerHighest,
      icon: icon,
      iconColor: colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(title, style: titleTextStyle),
      content: resolvedContent,
      scrollable: scrollable,
      contentPadding:
          contentPadding ??
          const EdgeInsets.fromLTRB(
            AppSizes.spacingLg,
            AppSizes.spacingMd,
            AppSizes.spacingLg,
            AppSizes.spacingSm,
          ),
      actionsPadding:
          actionsPadding ??
          const EdgeInsets.fromLTRB(
            AppSizes.spacingSm,
            AppSizes.spacingXs,
            AppSizes.spacingSm,
            AppSizes.spacingSm,
          ),
      actions: resolvedActions,
    );
  }

  List<Widget> _resolveActions() {
    if (actions.isEmpty) {
      return const <Widget>[];
    }
    if (actionLayout == AppDialogActionLayout.horizontal) {
      return actions;
    }
    return <Widget>[
      SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _withSpacing(actions),
        ),
      ),
    ];
  }

  Widget _buildContentWithMaxHeight(BuildContext context) {
    final double maxHeight =
        MediaQuery.sizeOf(context).height * _dialogContentMaxHeightFactor;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: content,
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    if (widgets.length <= 1) {
      return widgets;
    }

    final List<Widget> spaced = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      spaced.add(widgets[i]);
      final bool isLastItem = i == widgets.length - 1;
      if (!isLastItem) {
        spaced.add(const SizedBox(height: AppSizes.spacingXs));
      }
    }
    return spaced;
  }
}

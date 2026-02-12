import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title, super.key,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

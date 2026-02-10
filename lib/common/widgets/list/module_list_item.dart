import 'package:flutter/material.dart';

import '../indicator/app_badge.dart';

class ModuleListItem extends StatelessWidget {
  const ModuleListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: AppBadge(label: progressLabel),
      onTap: onTap,
    );
  }
}

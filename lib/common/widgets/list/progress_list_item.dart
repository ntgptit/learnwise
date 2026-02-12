import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';
import '../indicator/linear_progress.dart';

class ProgressListItem extends StatelessWidget {
  const ProgressListItem({
    required this.title, required this.progress, super.key,
    this.onTap,
  });

  final String title;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSizes.spacingXs),
        child: AppLinearProgress(value: progress),
      ),
      onTap: onTap,
    );
  }
}

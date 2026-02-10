import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(AppSizes.spacingLg),
  });

  final String? message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
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
    );
  }
}

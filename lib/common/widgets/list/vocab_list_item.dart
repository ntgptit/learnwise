import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class VocabListItem extends StatelessWidget {
  const VocabListItem({
    required this.term, required this.meaning, super.key,
    this.onTap,
    this.trailing,
  });

  final String term;
  final String meaning;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(term),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSizes.spacing2Xs),
        child: Text(meaning),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

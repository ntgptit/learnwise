// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class TagInput extends StatelessWidget {
  const TagInput({
    required this.controller, required this.tags, required this.onAddRequested, required this.onSubmitted, required this.onRemoveRequested, required this.label, required this.hint, super.key,
  });

  final TextEditingController controller;
  final List<String> tags;
  final VoidCallback onAddRequested;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onRemoveRequested;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        const SizedBox(height: AppSizes.spacingXs),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: IconButton(
              onPressed: onAddRequested,
              icon: const Icon(Icons.add),
            ),
          ),
          onSubmitted: onSubmitted,
        ),
        if (tags.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSizes.spacingXs),
          Wrap(
            spacing: AppSizes.spacingXs,
            runSpacing: AppSizes.spacingXs,
            children: tags
                .map(
                  (tag) => InputChip(
                    label: Text(tag),
                    onDeleted: () => onRemoveRequested(tag),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

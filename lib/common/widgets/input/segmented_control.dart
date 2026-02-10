import 'package:flutter/material.dart';

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelectionChanged,
    this.emptySelectionAllowed = false,
  });

  final List<String> labels;
  final Set<int> selected;
  final ValueChanged<Set<int>> onSelectionChanged;
  final bool emptySelectionAllowed;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    return SegmentedButton<int>(
      segments: List<ButtonSegment<int>>.generate(labels.length, (int index) {
        return ButtonSegment<int>(value: index, label: Text(labels[index]));
      }),
      selected: selected,
      emptySelectionAllowed: emptySelectionAllowed,
      onSelectionChanged: onSelectionChanged,
    );
  }
}

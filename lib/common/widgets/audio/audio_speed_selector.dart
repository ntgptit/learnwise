import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class AudioSpeedOption {
  const AudioSpeedOption({required this.value, required this.label});

  final double value;
  final String label;
}

class AudioSpeedSelector extends StatelessWidget {
  const AudioSpeedSelector({
    required this.selectedValue, required this.options, required this.onChanged, super.key,
  });

  final double selectedValue;
  final List<AudioSpeedOption> options;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.spacingXs,
      children: options
          .map(
            (option) => ChoiceChip(
              selected: option.value == selectedValue,
              label: Text(option.label),
              onSelected: (_) => onChanged(option.value),
            ),
          )
          .toList(),
    );
  }
}

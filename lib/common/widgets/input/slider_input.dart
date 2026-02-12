import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class SliderInput extends StatelessWidget {
  const SliderInput({
    required this.value, required this.onChanged, required this.min, required this.max, required this.displayValueText, super.key,
    this.divisions,
    this.label,
  }) : assert(min < max, 'min must be less than max.');

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final String displayValueText;
  final int? divisions;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(label!)),
              Text(displayValueText),
            ],
          ),
          const SizedBox(height: AppSizes.spacing2Xs),
        ],
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

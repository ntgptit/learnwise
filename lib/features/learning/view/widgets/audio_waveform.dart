// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';

class AudioWaveform extends StatelessWidget {
  const AudioWaveform({
    required this.amplitudes,
    super.key,
    this.height = 28,
    this.minBarHeight = 4,
    this.barWidth = 3,
    this.barSpacing = 2,
    this.color,
  }) : assert(height > 0, 'height must be > 0.'),
       assert(minBarHeight >= 0, 'minBarHeight must be >= 0.'),
       assert(barWidth > 0, 'barWidth must be > 0.'),
       assert(barSpacing >= 0, 'barSpacing must be >= 0.');

  final List<double> amplitudes;
  final double height;
  final double minBarHeight;
  final double barWidth;
  final double barSpacing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final List<double> safeAmplitudes = amplitudes.isEmpty
        ? const <double>[0, 0, 0, 0, 0, 0]
        : amplitudes;
    final double safeHeight = height <= 0 ? 28 : height;
    final double safeMinBarHeight = minBarHeight < 0 ? 0 : minBarHeight;
    final double safeBarWidth = barWidth <= 0 ? 3 : barWidth;
    final double safeBarSpacing = barSpacing < 0 ? 0 : barSpacing;
    final Color effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final List<Widget> waveformBars = safeAmplitudes.map((amplitude) {
      final double clampedAmplitude = amplitude.clamp(0, 1).toDouble();
      final double barHeight =
          safeMinBarHeight + (safeHeight - safeMinBarHeight) * clampedAmplitude;

      return Container(
        width: safeBarWidth,
        height: barHeight,
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(AppSizes.size2),
        ),
      );
    }).toList();

    return LwSpacedRow(
      spacing: safeBarSpacing,
      mainAxisSize: MainAxisSize.min,
      children: waveformBars,
    );
  }
}

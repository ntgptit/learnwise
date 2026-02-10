import 'package:flutter/material.dart';

typedef QuizTimerFormat = String Function(int remainingSeconds);

class QuizTimer extends StatelessWidget {
  const QuizTimer({
    super.key,
    required this.remainingSeconds,
    this.style,
    this.formatter,
  }) : assert(remainingSeconds >= 0, 'remainingSeconds must be >= 0.');

  final int remainingSeconds;
  final TextStyle? style;
  final QuizTimerFormat? formatter;

  @override
  Widget build(BuildContext context) {
    final int safeRemainingSeconds = remainingSeconds < 0
        ? 0
        : remainingSeconds;
    final String text =
        formatter?.call(safeRemainingSeconds) ??
        _formatDefault(safeRemainingSeconds);
    return Text(text, style: style);
  }

  String _formatDefault(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = secs.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

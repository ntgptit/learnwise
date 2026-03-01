import 'package:flutter/material.dart';

class LwAudioPlayerButton extends StatelessWidget {
  const LwAudioPlayerButton({
    required this.isPlaying,
    super.key,
    this.onPressed,
  });

  final bool isPlaying;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
    );
  }
}

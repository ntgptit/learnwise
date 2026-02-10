import 'package:flutter/material.dart';

class AudioPlayerButton extends StatelessWidget {
  const AudioPlayerButton({super.key, required this.isPlaying, this.onPressed});

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

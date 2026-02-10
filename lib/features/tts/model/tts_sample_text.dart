import 'package:flutter/foundation.dart';

import 'tts_models.dart';

@immutable
class TtsSampleText {
  const TtsSampleText({
    required this.label,
    required this.text,
    required this.mode,
  });

  final String label;
  final String text;
  final TtsLanguageMode mode;
}

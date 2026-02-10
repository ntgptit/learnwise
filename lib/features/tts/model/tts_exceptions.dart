sealed class TtsException implements Exception {
  const TtsException(this.cause);

  final Object? cause;
}

class TtsInitException extends TtsException {
  const TtsInitException([super.cause]);
}

class TtsLoadVoicesException extends TtsException {
  const TtsLoadVoicesException([super.cause]);
}

class TtsSpeakException extends TtsException {
  const TtsSpeakException([super.cause]);
}

class TtsStopException extends TtsException {
  const TtsStopException([super.cause]);
}

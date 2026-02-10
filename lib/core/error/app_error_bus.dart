import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'error_code.dart';

part 'app_error_bus.freezed.dart';
part 'app_error_bus.g.dart';

@freezed
sealed class AppErrorEvent with _$AppErrorEvent {
  const factory AppErrorEvent({required int id, required AppErrorCode code}) =
      _AppErrorEvent;
}

@Riverpod(keepAlive: true)
class AppErrorBus extends _$AppErrorBus {
  int _nextErrorId = 0;

  @override
  AppErrorEvent? build() {
    return null;
  }

  void report(AppErrorCode code) {
    _nextErrorId++;
    state = AppErrorEvent(id: _nextErrorId, code: code);
  }

  void consume(int eventId) {
    if (state?.id != eventId) {
      return;
    }
    state = null;
  }
}

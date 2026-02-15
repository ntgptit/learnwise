import 'package:flutter/foundation.dart';

@immutable
class StudyInteractionFeedbackState<T> {
  const StudyInteractionFeedbackState({
    required this.successIds,
    required this.errorIds,
    required this.isLocked,
  });

  final Set<T> successIds;
  final Set<T> errorIds;
  final bool isLocked;

  bool get hasFeedback {
    if (successIds.isNotEmpty) {
      return true;
    }
    if (errorIds.isNotEmpty) {
      return true;
    }
    return false;
  }
}

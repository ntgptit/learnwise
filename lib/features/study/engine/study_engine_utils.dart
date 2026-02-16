import 'dart:math';

import '../model/study_constants.dart';

class StudyEngineUtils {
  const StudyEngineUtils._();

  static int resolveSafeInitialIndex({
    required int requestedIndex,
    required int itemCount,
  }) {
    if (itemCount <= StudyConstants.defaultIndex) {
      return StudyConstants.defaultIndex;
    }
    final int maxIndex = itemCount - 1;
    return requestedIndex.clamp(StudyConstants.defaultIndex, maxIndex);
  }

  static List<T> shuffledCopy<T>({
    required List<T> values,
    required Random random,
  }) {
    final List<T> copy = List<T>.from(values);
    copy.shuffle(random);
    return copy;
  }
}

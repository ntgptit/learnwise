import '../../../../core/utils/string_utils.dart';
import 'study_constants.dart';

enum StudyMode { review, match, guess, recall, fill }

const List<StudyMode> _defaultStudyModeCycle = <StudyMode>[
  StudyMode.review,
  StudyMode.match,
  StudyMode.guess,
  StudyMode.recall,
  StudyMode.fill,
];

extension StudyModeApiX on StudyMode {
  String get apiValue {
    return switch (this) {
      StudyMode.review => StudyConstants.modeReview,
      StudyMode.match => StudyConstants.modeMatch,
      StudyMode.guess => StudyConstants.modeGuess,
      StudyMode.recall => StudyConstants.modeRecall,
      StudyMode.fill => StudyConstants.modeFill,
    };
  }

  static StudyMode fromApiValue(String rawValue) {
    final String normalized = StringUtils.normalizeLower(rawValue);
    if (normalized == StudyConstants.modeReview) {
      return StudyMode.review;
    }
    if (normalized == StudyConstants.modeMatch) {
      return StudyMode.match;
    }
    if (normalized == StudyConstants.modeGuess) {
      return StudyMode.guess;
    }
    if (normalized == StudyConstants.modeRecall) {
      return StudyMode.recall;
    }
    if (normalized == StudyConstants.modeFill) {
      return StudyMode.fill;
    }
    throw UnsupportedError(
      '${StudyConstants.unsupportedModeMessagePrefix}$rawValue',
    );
  }
}

List<StudyMode> buildStudyModeCycle({required StudyMode startMode}) {
  final int startIndex = _defaultStudyModeCycle.indexOf(startMode);
  if (startIndex <= StudyConstants.defaultIndex) {
    return List<StudyMode>.unmodifiable(_defaultStudyModeCycle);
  }
  final List<StudyMode> cycle = <StudyMode>[];
  final int modeCount = _defaultStudyModeCycle.length;
  int offset = StudyConstants.defaultIndex;
  while (offset < modeCount) {
    final int index = (startIndex + offset) % modeCount;
    cycle.add(_defaultStudyModeCycle[index]);
    offset++;
  }
  return List<StudyMode>.unmodifiable(cycle);
}

List<StudyMode> getDefaultStudyModeCycle() {
  return List<StudyMode>.unmodifiable(_defaultStudyModeCycle);
}

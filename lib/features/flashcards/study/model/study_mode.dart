import '../../../../core/utils/string_utils.dart';
import 'study_constants.dart';

enum StudyMode { review, match, guess, recall, fill }

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
    final String normalized = StringUtils.normalize(rawValue).toLowerCase();
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

class StudyConstants {
  const StudyConstants._();

  static const String decksResourcePath = '/decks';
  static const String studySessionsPathSegment = 'study-sessions';
  static const String studySessionsResourcePath = '/study-sessions';
  static const String studySessionEventsPathSegment = 'events';
  static const String studySessionCompletePathSegment = 'complete';

  static const String modeReview = 'review';
  static const String modeMatch = 'match';
  static const String modeGuess = 'guess';
  static const String modeRecall = 'recall';
  static const String modeFill = 'fill';

  static const String eventReviewNext = 'review.next';
  static const String eventReviewPrevious = 'review.previous';
  static const String eventReviewGotoIndex = 'review.gotoIndex';
  static const String eventMatchSelectLeft = 'match.selectLeft';
  static const String eventMatchSelectRight = 'match.selectRight';

  static const String matchTileSideLeft = 'LEFT';
  static const String matchTileSideRight = 'RIGHT';
  static const String matchTileFlashPrefixLeft = 'left:';
  static const String matchTileFlashPrefixRight = 'right:';
  static const String feedbackSuccess = 'SUCCESS';
  static const String feedbackError = 'ERROR';
  static const String defaultClientEventPrefix = 'study-event';

  static const int defaultIndex = 0;
  static const int defaultClientSequence = 0;
  static const int defaultSeed = 37;
  static const int defaultGuessOptionCount = 4;
  static const int minimumMatchPairCount = 2;
  static const int fillToleranceDistance = 1;
  static const int audioPlayingIndicatorDurationMs = 1400;
  static const int localMatchFeedbackDurationMs = 650;
  static const String matchBoardUnitId = 'match_board';
  static const String unsupportedModeMessagePrefix =
      'Study mode is not registered: ';
}

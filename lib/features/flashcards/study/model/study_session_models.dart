import '../../../../core/utils/string_utils.dart';
import 'study_constants.dart';
import 'study_mode.dart';

const String _jsonKeySessionId = 'sessionId';
const String _jsonKeyDeckId = 'deckId';
const String _jsonKeyMode = 'mode';
const String _jsonKeyStatus = 'status';
const String _jsonKeyCurrentIndex = 'currentIndex';
const String _jsonKeyTotalUnits = 'totalUnits';
const String _jsonKeyCorrectCount = 'correctCount';
const String _jsonKeyWrongCount = 'wrongCount';
const String _jsonKeyCompleted = 'completed';
const String _jsonKeyStartedAt = 'startedAt';
const String _jsonKeyCompletedAt = 'completedAt';
const String _jsonKeyReviewItems = 'reviewItems';
const String _jsonKeyLeftTiles = 'leftTiles';
const String _jsonKeyRightTiles = 'rightTiles';
const String _jsonKeyLastAttemptResult = 'lastAttemptResult';

const String _jsonKeySessionItemId = 'sessionItemId';
const String _jsonKeyFlashcardId = 'flashcardId';
const String _jsonKeyItemOrder = 'itemOrder';
const String _jsonKeyFrontText = 'frontText';
const String _jsonKeyBackText = 'backText';

const String _jsonKeyTileId = 'tileId';
const String _jsonKeyPairKey = 'pairKey';
const String _jsonKeySide = 'side';
const String _jsonKeyLabel = 'label';
const String _jsonKeyTileOrder = 'tileOrder';
const String _jsonKeyMatched = 'matched';
const String _jsonKeyHidden = 'hidden';
const String _jsonKeySelected = 'selected';
const String _jsonKeySuccessFlash = 'successFlash';
const String _jsonKeyErrorFlash = 'errorFlash';

const String _jsonKeyFeedbackStatus = 'feedbackStatus';
const String _jsonKeyLeftTileId = 'leftTileId';
const String _jsonKeyRightTileId = 'rightTileId';
const String _jsonKeyInteractionLocked = 'interactionLocked';
const String _jsonKeyFeedbackUntil = 'feedbackUntil';

const String _jsonKeySeed = 'seed';
const String _jsonKeyClientEventId = 'clientEventId';
const String _jsonKeyClientSequence = 'clientSequence';
const String _jsonKeyEventType = 'eventType';
const String _jsonKeyTargetTileId = 'targetTileId';
const String _jsonKeyTargetIndex = 'targetIndex';

enum StudySessionEventType {
  reviewNext,
  reviewPrevious,
  reviewGotoIndex,
  matchSelectLeft,
  matchSelectRight,
}

extension StudySessionEventTypeApiX on StudySessionEventType {
  String get apiValue {
    return switch (this) {
      StudySessionEventType.reviewNext => StudyConstants.eventReviewNext,
      StudySessionEventType.reviewPrevious =>
        StudyConstants.eventReviewPrevious,
      StudySessionEventType.reviewGotoIndex =>
        StudyConstants.eventReviewGotoIndex,
      StudySessionEventType.matchSelectLeft =>
        StudyConstants.eventMatchSelectLeft,
      StudySessionEventType.matchSelectRight =>
        StudyConstants.eventMatchSelectRight,
    };
  }
}

class StudySessionStartRequest {
  const StudySessionStartRequest({required this.mode, required this.seed});

  final StudyMode mode;
  final int seed;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{_jsonKeyMode: mode.apiValue, _jsonKeySeed: seed};
  }
}

class StudySessionEventRequest {
  const StudySessionEventRequest({
    required this.clientEventId,
    required this.clientSequence,
    required this.eventType,
    this.targetTileId,
    this.targetIndex,
  });

  final String clientEventId;
  final int clientSequence;
  final StudySessionEventType eventType;
  final int? targetTileId;
  final int? targetIndex;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = <String, dynamic>{
      _jsonKeyClientEventId: clientEventId,
      _jsonKeyClientSequence: clientSequence,
      _jsonKeyEventType: eventType.apiValue,
    };
    if (targetTileId != null) {
      payload[_jsonKeyTargetTileId] = targetTileId;
    }
    if (targetIndex != null) {
      payload[_jsonKeyTargetIndex] = targetIndex;
    }
    return payload;
  }
}

class StudySessionResponseModel {
  const StudySessionResponseModel({
    required this.sessionId,
    required this.deckId,
    required this.mode,
    required this.status,
    required this.currentIndex,
    required this.totalUnits,
    required this.correctCount,
    required this.wrongCount,
    required this.completed,
    required this.startedAt,
    required this.completedAt,
    required this.reviewItems,
    required this.leftTiles,
    required this.rightTiles,
    required this.lastAttemptResult,
  });

  final int sessionId;
  final int deckId;
  final StudyMode mode;
  final String status;
  final int currentIndex;
  final int totalUnits;
  final int correctCount;
  final int wrongCount;
  final bool completed;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<StudyReviewItemModel> reviewItems;
  final List<StudyMatchTileModel> leftTiles;
  final List<StudyMatchTileModel> rightTiles;
  final StudyAttemptResultModel? lastAttemptResult;

  factory StudySessionResponseModel.fromJson(Map<String, dynamic> json) {
    return StudySessionResponseModel(
      sessionId: _readRequiredInt(json: json, key: _jsonKeySessionId),
      deckId: _readRequiredInt(json: json, key: _jsonKeyDeckId),
      mode: StudyModeApiX.fromApiValue(
        _readRequiredString(json: json, key: _jsonKeyMode),
      ),
      status: _readRequiredString(json: json, key: _jsonKeyStatus),
      currentIndex: _readRequiredInt(json: json, key: _jsonKeyCurrentIndex),
      totalUnits: _readRequiredInt(json: json, key: _jsonKeyTotalUnits),
      correctCount: _readRequiredInt(json: json, key: _jsonKeyCorrectCount),
      wrongCount: _readRequiredInt(json: json, key: _jsonKeyWrongCount),
      completed: _readRequiredBool(json: json, key: _jsonKeyCompleted),
      startedAt: _readRequiredDateTime(json: json, key: _jsonKeyStartedAt),
      completedAt: _readNullableDateTime(json: json, key: _jsonKeyCompletedAt),
      reviewItems: _readList(
        json: json,
        key: _jsonKeyReviewItems,
        itemDecoder: (item) => StudyReviewItemModel.fromJson(item),
      ),
      leftTiles: _readList(
        json: json,
        key: _jsonKeyLeftTiles,
        itemDecoder: (item) => StudyMatchTileModel.fromJson(item),
      ),
      rightTiles: _readList(
        json: json,
        key: _jsonKeyRightTiles,
        itemDecoder: (item) => StudyMatchTileModel.fromJson(item),
      ),
      lastAttemptResult: _readNullableMap(
        json: json,
        key: _jsonKeyLastAttemptResult,
      )?.let(StudyAttemptResultModel.fromJson),
    );
  }
}

class StudyReviewItemModel {
  const StudyReviewItemModel({
    required this.sessionItemId,
    required this.flashcardId,
    required this.itemOrder,
    required this.frontText,
    required this.backText,
  });

  final int sessionItemId;
  final int flashcardId;
  final int itemOrder;
  final String frontText;
  final String backText;

  factory StudyReviewItemModel.fromJson(Map<String, dynamic> json) {
    return StudyReviewItemModel(
      sessionItemId: _readRequiredInt(json: json, key: _jsonKeySessionItemId),
      flashcardId: _readRequiredInt(json: json, key: _jsonKeyFlashcardId),
      itemOrder: _readRequiredInt(json: json, key: _jsonKeyItemOrder),
      frontText: _readRequiredString(json: json, key: _jsonKeyFrontText),
      backText: _readRequiredString(json: json, key: _jsonKeyBackText),
    );
  }
}

class StudyMatchTileModel {
  const StudyMatchTileModel({
    required this.tileId,
    required this.pairKey,
    required this.side,
    required this.label,
    required this.tileOrder,
    required this.matched,
    required this.hidden,
    required this.selected,
    required this.successFlash,
    required this.errorFlash,
  });

  final int tileId;
  final int pairKey;
  final String side;
  final String label;
  final int tileOrder;
  final bool matched;
  final bool hidden;
  final bool selected;
  final bool successFlash;
  final bool errorFlash;

  factory StudyMatchTileModel.fromJson(Map<String, dynamic> json) {
    return StudyMatchTileModel(
      tileId: _readRequiredInt(json: json, key: _jsonKeyTileId),
      pairKey: _readRequiredInt(json: json, key: _jsonKeyPairKey),
      side: _readRequiredString(json: json, key: _jsonKeySide),
      label: _readRequiredString(json: json, key: _jsonKeyLabel),
      tileOrder: _readRequiredInt(json: json, key: _jsonKeyTileOrder),
      matched: _readRequiredBool(json: json, key: _jsonKeyMatched),
      hidden: _readRequiredBool(json: json, key: _jsonKeyHidden),
      selected: _readRequiredBool(json: json, key: _jsonKeySelected),
      successFlash: _readRequiredBool(json: json, key: _jsonKeySuccessFlash),
      errorFlash: _readRequiredBool(json: json, key: _jsonKeyErrorFlash),
    );
  }

  bool get isLeftTile {
    return side.toUpperCase() == StudyConstants.matchTileSideLeft;
  }
}

class StudyAttemptResultModel {
  const StudyAttemptResultModel({
    required this.feedbackStatus,
    required this.leftTileId,
    required this.rightTileId,
    required this.interactionLocked,
    required this.feedbackUntil,
  });

  final String? feedbackStatus;
  final int? leftTileId;
  final int? rightTileId;
  final bool interactionLocked;
  final DateTime? feedbackUntil;

  factory StudyAttemptResultModel.fromJson(Map<String, dynamic> json) {
    return StudyAttemptResultModel(
      feedbackStatus: _readNullableString(
        json: json,
        key: _jsonKeyFeedbackStatus,
      ),
      leftTileId: _readNullableInt(json: json, key: _jsonKeyLeftTileId),
      rightTileId: _readNullableInt(json: json, key: _jsonKeyRightTileId),
      interactionLocked: _readRequiredBool(
        json: json,
        key: _jsonKeyInteractionLocked,
      ),
      feedbackUntil: _readNullableDateTime(
        json: json,
        key: _jsonKeyFeedbackUntil,
      ),
    );
  }

  bool get isSuccess {
    final String? normalizedStatus = StringUtils.normalizeNullable(
      feedbackStatus,
    );
    if (normalizedStatus == null) {
      return false;
    }
    return normalizedStatus.toUpperCase() == StudyConstants.feedbackSuccess;
  }

  bool get isError {
    final String? normalizedStatus = StringUtils.normalizeNullable(
      feedbackStatus,
    );
    if (normalizedStatus == null) {
      return false;
    }
    return normalizedStatus.toUpperCase() == StudyConstants.feedbackError;
  }
}

Map<String, dynamic>? _readNullableMap({
  required Map<String, dynamic> json,
  required String key,
}) {
  final dynamic rawValue = json[key];
  if (rawValue == null) {
    return null;
  }
  if (rawValue is Map<String, dynamic>) {
    return rawValue;
  }
  if (rawValue is Map) {
    return Map<String, dynamic>.from(rawValue);
  }
  throw FormatException('Invalid map for key: $key');
}

int _readRequiredInt({
  required Map<String, dynamic> json,
  required String key,
}) {
  final int? value = _readNullableInt(json: json, key: key);
  if (value != null) {
    return value;
  }
  throw FormatException('Missing int for key: $key');
}

int? _readNullableInt({
  required Map<String, dynamic> json,
  required String key,
}) {
  final dynamic rawValue = json[key];
  if (rawValue == null) {
    return null;
  }
  if (rawValue is int) {
    return rawValue;
  }
  if (rawValue is num) {
    return rawValue.toInt();
  }
  throw FormatException('Invalid int for key: $key');
}

String _readRequiredString({
  required Map<String, dynamic> json,
  required String key,
}) {
  final String? value = _readNullableString(json: json, key: key);
  if (value != null) {
    return value;
  }
  throw FormatException('Missing string for key: $key');
}

String? _readNullableString({
  required Map<String, dynamic> json,
  required String key,
}) {
  final dynamic rawValue = json[key];
  if (rawValue == null) {
    return null;
  }
  if (rawValue is String) {
    return rawValue;
  }
  throw FormatException('Invalid string for key: $key');
}

bool _readRequiredBool({
  required Map<String, dynamic> json,
  required String key,
}) {
  final dynamic rawValue = json[key];
  if (rawValue is bool) {
    return rawValue;
  }
  throw FormatException('Invalid bool for key: $key');
}

DateTime _readRequiredDateTime({
  required Map<String, dynamic> json,
  required String key,
}) {
  final DateTime? value = _readNullableDateTime(json: json, key: key);
  if (value != null) {
    return value;
  }
  throw FormatException('Missing datetime for key: $key');
}

DateTime? _readNullableDateTime({
  required Map<String, dynamic> json,
  required String key,
}) {
  final String? rawValue = _readNullableString(json: json, key: key);
  if (rawValue == null) {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(rawValue);
  if (parsed != null) {
    return parsed;
  }
  throw FormatException('Invalid datetime for key: $key');
}

List<T> _readList<T>({
  required Map<String, dynamic> json,
  required String key,
  required T Function(Map<String, dynamic>) itemDecoder,
}) {
  final dynamic rawValue = json[key];
  if (rawValue is List) {
    return rawValue
        .map((dynamic item) {
          if (item is Map<String, dynamic>) {
            return itemDecoder(item);
          }
          if (item is Map) {
            return itemDecoder(Map<String, dynamic>.from(item));
          }
          throw FormatException('Invalid list item for key: $key');
        })
        .toList(growable: false);
  }
  throw FormatException('Invalid list for key: $key');
}

extension _NullableMapX on Map<String, dynamic>? {
  T? let<T>(T Function(Map<String, dynamic>) transform) {
    final Map<String, dynamic>? value = this;
    if (value == null) {
      return null;
    }
    return transform(value);
  }
}

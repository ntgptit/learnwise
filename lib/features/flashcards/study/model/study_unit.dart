import 'package:flutter/foundation.dart';

@immutable
abstract class StudyUnit {
  const StudyUnit({required this.unitId});

  final String unitId;
}

@immutable
class ReviewUnit extends StudyUnit {
  const ReviewUnit({
    required super.unitId,
    required this.flashcardId,
    required this.frontText,
    required this.backText,
    required this.note,
  });

  final int flashcardId;
  final String frontText;
  final String backText;
  final String note;
}

@immutable
class GuessOption {
  const GuessOption({required this.id, required this.label});

  final String id;
  final String label;
}

@immutable
class GuessUnit extends StudyUnit {
  const GuessUnit({
    required super.unitId,
    required this.prompt,
    required this.correctOptionId,
    required this.options,
  });

  final String prompt;
  final String correctOptionId;
  final List<GuessOption> options;
}

@immutable
class RecallUnit extends StudyUnit {
  const RecallUnit({
    required super.unitId,
    required this.prompt,
    required this.answer,
  });

  final String prompt;
  final String answer;
}

@immutable
class FillUnit extends StudyUnit {
  const FillUnit({
    required super.unitId,
    required this.prompt,
    required this.expectedAnswer,
  });

  final String prompt;
  final String expectedAnswer;
}

@immutable
class MatchEntry {
  const MatchEntry({required this.id, required this.label});

  final int id;
  final String label;
}

enum MatchAttemptResultType {
  correct,
  wrong,
}

@immutable
class MatchAttemptResult {
  const MatchAttemptResult({
    required this.leftId,
    required this.rightId,
    required this.type,
  });

  final int leftId;
  final int rightId;
  final MatchAttemptResultType type;

  bool get isCorrect => type == MatchAttemptResultType.correct;
}

@immutable
class MatchUnit extends StudyUnit {
  const MatchUnit({
    required super.unitId,
    required this.leftEntries,
    required this.rightEntries,
    required this.matchedIds,
    required this.selectedLeftId,
    required this.selectedRightId,
    required this.lastAttemptResult,
  });

  final List<MatchEntry> leftEntries;
  final List<MatchEntry> rightEntries;
  final Set<int> matchedIds;
  final int? selectedLeftId;
  final int? selectedRightId;
  final MatchAttemptResult? lastAttemptResult;

  MatchUnit copyWith({
    List<MatchEntry>? leftEntries,
    List<MatchEntry>? rightEntries,
    Set<int>? matchedIds,
    int? selectedLeftId,
    bool clearSelectedLeftId = false,
    int? selectedRightId,
    bool clearSelectedRightId = false,
    MatchAttemptResult? lastAttemptResult,
    bool clearLastAttemptResult = false,
  }) {
    final int? nextSelectedLeftId = clearSelectedLeftId
        ? null
        : (selectedLeftId ?? this.selectedLeftId);
    final int? nextSelectedRightId = clearSelectedRightId
        ? null
        : (selectedRightId ?? this.selectedRightId);
    final MatchAttemptResult? nextLastAttemptResult = clearLastAttemptResult
        ? null
        : (lastAttemptResult ?? this.lastAttemptResult);
    return MatchUnit(
      unitId: unitId,
      leftEntries: leftEntries ?? this.leftEntries,
      rightEntries: rightEntries ?? this.rightEntries,
      matchedIds: matchedIds ?? this.matchedIds,
      selectedLeftId: nextSelectedLeftId,
      selectedRightId: nextSelectedRightId,
      lastAttemptResult: nextLastAttemptResult,
    );
  }
}

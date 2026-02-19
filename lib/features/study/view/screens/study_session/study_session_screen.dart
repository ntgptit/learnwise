import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/app/router/app_router.dart';
import 'package:learnwise/app/theme/semantic_colors.dart';
import 'package:learnwise/common/styles/app_screen_tokens.dart';
import 'package:learnwise/common/widgets/widgets.dart';
import 'package:learnwise/core/utils/string_utils.dart';
import 'package:learnwise/features/decks/viewmodel/deck_audio_settings_viewmodel.dart';
import 'package:learnwise/features/profile/model/profile_models.dart';
import 'package:learnwise/features/study/model/study_constants.dart';
import 'package:learnwise/features/study/model/study_cycle_progress.dart';
import 'package:learnwise/features/study/model/study_mode.dart';
import 'package:learnwise/features/study/model/study_session_args.dart';
import 'package:learnwise/features/study/model/study_unit.dart';
import 'package:learnwise/features/tts/viewmodel/tts_viewmodel.dart';
import 'package:learnwise/features/study/viewmodel/study_session_viewmodel.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import 'builders/mode_content/fill_mode_content_builder.dart';
import 'builders/mode_content/guess_mode_content_builder.dart';
import 'builders/mode_content/match_mode_content_builder.dart';
import 'builders/mode_content/recall_mode_content_builder.dart';
import 'builders/mode_content/review_mode_content_builder.dart';
import 'builders/mode_content/study_mode_content_builder.dart';

part 'parts/study_session_screen_state.dart';
part 'parts/study_session_body.dart';
part 'parts/study_unit_body.dart';
part 'parts/study_progress_header.dart';
part 'parts/study_cycle_mode_progress.dart';
part 'parts/study_completed_card.dart';

// quality-guard: allow-long-function
final Map<StudyMode, StudyModeContentBuilder> _modeContentBuilderRegistry =
    <StudyMode, StudyModeContentBuilder>{
      StudyMode.review: const ReviewModeContentBuilder(),
      StudyMode.guess: const GuessModeContentBuilder(),
      StudyMode.recall: const RecallModeContentBuilder(),
      StudyMode.fill: const FillModeContentBuilder(),
      StudyMode.match: const MatchModeContentBuilder(),
    };

StudyModeContentBuilder? _resolveModeContentBuilder(StudyMode mode) {
  return _modeContentBuilderRegistry[mode];
}

class FlashcardStudySessionScreen extends ConsumerStatefulWidget {
  const FlashcardStudySessionScreen({required this.args, super.key});

  final StudySessionArgs args;

  @override
  ConsumerState<FlashcardStudySessionScreen> createState() {
    return _FlashcardStudySessionScreenState();
  }
}

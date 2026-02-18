// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import 'package:learnwise/common/styles/app_screen_tokens.dart';
import '../../../../../model/study_mode.dart';
import '../../../../../model/study_unit.dart';
import '../../../../../viewmodel/study_session_viewmodel.dart';
import 'base_study_mode_content_builder.dart';
import '../../../../widgets/review_study_mode_view.dart';

class ReviewModeContentBuilder extends BaseStudyModeContentBuilder {
  const ReviewModeContentBuilder();

  @override
  StudyMode get mode {
    return StudyMode.review;
  }

  @override
  String resolveModeLabel(AppLocalizations l10n) {
    return l10n.flashcardsStudyModeReview;
  }

  @override
  IconData resolveModeIcon() {
    return Icons.visibility_outlined;
  }

  @override
  bool get centerTitle {
    return false;
  }

  @override
  List<Widget> buildAppBarActions(ModeAppBarActionBuildContext context) {
    const String settingsActionValue = 'settings';
    return <Widget>[
      IconButton(
        onPressed: () {
          context.showToast(context.l10n.flashcardsStudyTextScaleToast);
        },
        tooltip: context.l10n.flashcardsStudyTextScaleTooltip,
        iconSize: FlashcardStudySessionTokens.iconSize,
        icon: const Icon(Icons.text_fields_rounded),
      ),
      Consumer(
        builder: (contextValue, ref, child) {
          final bool isPlayingAudio = ref.watch(
            context.provider.select(
              (value) => value.playingFlashcardId != null,
            ),
          );
          final StudySessionController controller = ref.read(
            context.provider.notifier,
          );
          final String frontText = _resolveCurrentReviewFrontText(
            ref: ref,
            provider: context.provider,
          );
          return IconButton(
            isSelected: isPlayingAudio,
            onPressed: () {
              controller.playCurrentAudio();
              if (frontText.isEmpty) {
                return;
              }
              context.showToast(
                context.l10n.flashcardsAudioPlayToast(frontText),
              );
            },
            tooltip: context.l10n.flashcardsPlayAudioTooltip,
            iconSize: FlashcardStudySessionTokens.iconSize,
            icon: const Icon(Icons.volume_up_outlined),
            selectedIcon: const Icon(Icons.graphic_eq_rounded),
          );
        },
      ),
      PopupMenuButton<String>(
        tooltip: context.l10n.flashcardsMoreActionsTooltip,
        itemBuilder: (contextValue) {
          return <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: settingsActionValue,
              child: Text(context.l10n.flashcardsFlipStudySettingsTooltip),
            ),
          ];
        },
        onSelected: (value) {
          if (value != settingsActionValue) {
            return;
          }
          context.showToast(context.l10n.flashcardsFlipStudySettingsToast);
        },
      ),
    ];
  }

  @override
  Widget buildContent(ModeContentBuildContext context) {
    final StudyUnit currentUnit = context.currentUnit;
    if (currentUnit is! ReviewUnit) {
      return const SizedBox.shrink();
    }
    return ReviewStudyModeView(
      units: context.state.reviewUnits,
      currentIndex: context.state.currentIndex,
      playingFlashcardId: context.state.playingFlashcardId,
      onPageChanged: context.controller.goTo,
      onAudioPressedFor: context.controller.playAudioFor,
      onNext: context.controller.next,
      onPrevious: context.controller.previous,
      l10n: context.l10n,
    );
  }

  String _resolveCurrentReviewFrontText({
    required WidgetRef ref,
    required StudySessionControllerProvider provider,
  }) {
    final StudyUnit? currentUnit = ref.read(provider).currentUnit;
    if (currentUnit is! ReviewUnit) {
      return '';
    }
    return currentUnit.frontText;
  }
}

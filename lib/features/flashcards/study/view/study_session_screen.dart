import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../core/utils/string_utils.dart';
import '../model/study_answer.dart';
import '../model/study_mode.dart';
import '../model/study_session_args.dart';
import '../model/study_unit.dart';
import '../viewmodel/study_session_viewmodel.dart';

// quality-guard: allow-large-file
// quality-guard: allow-long-function
typedef _ModeLabelResolver = String Function(AppLocalizations l10n);

typedef _StudyUnitRenderer =
    Widget Function({
      required BuildContext context,
      required StudyUnit unit,
      required StudySessionController controller,
      required AppLocalizations l10n,
      required TextEditingController fillController,
    });

final Map<StudyMode, _ModeLabelResolver> _modeLabelRegistry =
    <StudyMode, _ModeLabelResolver>{
      StudyMode.review: (l10n) => l10n.flashcardsStudyModeReview,
      StudyMode.match: (l10n) => l10n.flashcardsStudyModeMatch,
      StudyMode.guess: (l10n) => l10n.flashcardsStudyModeGuess,
      StudyMode.recall: (l10n) => l10n.flashcardsStudyModeRecall,
      StudyMode.fill: (l10n) => l10n.flashcardsStudyModeFill,
    };

final Map<Type, _StudyUnitRenderer> _unitRendererRegistry =
    <Type, _StudyUnitRenderer>{
      ReviewUnit: _renderReviewUnit,
      GuessUnit: _renderGuessUnit,
      RecallUnit: _renderRecallUnit,
      FillUnit: _renderFillUnit,
      MatchUnit: _renderMatchUnit,
    };

class FlashcardStudySessionScreen extends ConsumerStatefulWidget {
  const FlashcardStudySessionScreen({required this.args, super.key});

  final StudySessionArgs args;

  @override
  ConsumerState<FlashcardStudySessionScreen> createState() {
    return _FlashcardStudySessionScreenState();
  }
}

class _FlashcardStudySessionScreenState
    extends ConsumerState<FlashcardStudySessionScreen> {
  late final TextEditingController _fillController;

  @override
  void initState() {
    super.initState();
    _fillController = TextEditingController();
  }

  @override
  void dispose() {
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final provider = studySessionControllerProvider(widget.args);
    ref.listen<StudySessionState>(provider, (previous, next) {
      if (previous?.currentStep == next.currentStep) {
        return;
      }
      _fillController.clear();
    });
    final StudySessionState state = ref.watch(provider);
    final StudySessionController controller = ref.read(provider.notifier);
    final String modeLabel = _resolveModeLabel(
      mode: state.mode,
      l10n: l10n,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text('$modeLabel · ${widget.args.title}'),
        leading: IconButton(
          onPressed: () => context.pop(true),
          tooltip: l10n.flashcardsCloseTooltip,
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FlashcardStudySessionTokens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _StudyProgressHeader(state: state),
              const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
              Expanded(
                child: _buildBody(
                  context: context,
                  l10n: l10n,
                  state: state,
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AppLocalizations l10n,
    required StudySessionState state,
    required StudySessionController controller,
  }) {
    if (state.isCompleted) {
      return _StudyCompletedCard(
        state: state,
        l10n: l10n,
        onRestartPressed: controller.restart,
      );
    }
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit == null) {
      return const SizedBox.shrink();
    }
    final _StudyUnitRenderer? renderer = _unitRendererRegistry[
      currentUnit.runtimeType
    ];
    if (renderer == null) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      child: AppCard(
        variant: AppCardVariant.elevated,
        elevation: FlashcardStudySessionTokens.cardElevation,
        borderRadius: BorderRadius.circular(FlashcardStudySessionTokens.cardRadius),
        padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
        child: renderer(
          context: context,
          unit: currentUnit,
          controller: controller,
          l10n: l10n,
          fillController: _fillController,
        ),
      ),
    );
  }
}

class _StudyProgressHeader extends StatelessWidget {
  const _StudyProgressHeader({required this.state});

  final StudySessionState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double progressValue = _resolveProgressValue(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${state.currentStep} / ${state.totalSteps}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(FlashcardStudySessionTokens.progressRadius),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: FlashcardStudySessionTokens.progressHeight,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }

  double _resolveProgressValue(StudySessionState state) {
    if (state.totalSteps <= 0) {
      return 0;
    }
    return state.currentStep / state.totalSteps;
  }
}

class _StudyCompletedCard extends StatelessWidget {
  const _StudyCompletedCard({
    required this.state,
    required this.l10n,
    required this.onRestartPressed,
  });

  final StudySessionState state;
  final AppLocalizations l10n;
  final VoidCallback onRestartPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        variant: AppCardVariant.filled,
        borderRadius: BorderRadius.circular(FlashcardStudySessionTokens.cardRadius),
        padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.emoji_events_outlined),
            const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
            Text(
              l10n.flashcardsStudyCompletedTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
            Text(
              l10n.flashcardsStudyCompletedSummary(
                state.correctCount,
                state.wrongCount,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
            FilledButton(
              onPressed: onRestartPressed,
              child: Text(l10n.flashcardsStudyRestartLabel),
            ),
            const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
            OutlinedButton(
              onPressed: () => context.pop(true),
              child: Text(l10n.flashcardsCloseTooltip),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _renderReviewUnit({
  required BuildContext context,
  required StudyUnit unit,
  required StudySessionController controller,
  required AppLocalizations l10n,
  required TextEditingController fillController,
}) {
  final ReviewUnit reviewUnit = unit as ReviewUnit;
  final String? normalizedNote = StringUtils.normalizeNullable(reviewUnit.note);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(
        reviewUnit.frontText,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      Text(
        reviewUnit.backText,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (normalizedNote != null) ...<Widget>[
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        Text(
          normalizedNote,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      FilledButton.icon(
        onPressed: controller.next,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(l10n.flashcardsNextTooltip),
      ),
    ],
  );
}

Widget _renderGuessUnit({
  required BuildContext context,
  required StudyUnit unit,
  required StudySessionController controller,
  required AppLocalizations l10n,
  required TextEditingController fillController,
}) {
  final GuessUnit guessUnit = unit as GuessUnit;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(
        guessUnit.prompt,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      ...guessUnit.options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: FlashcardStudySessionTokens.answerSpacing,
          ),
          child: FilledButton.tonal(
            onPressed: () {
              controller.submitAnswer(GuessStudyAnswer(optionId: option.id));
              controller.next();
            },
            child: Text(option.label),
          ),
        );
      }),
    ],
  );
}

Widget _renderRecallUnit({
  required BuildContext context,
  required StudyUnit unit,
  required StudySessionController controller,
  required AppLocalizations l10n,
  required TextEditingController fillController,
}) {
  final RecallUnit recallUnit = unit as RecallUnit;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(
        recallUnit.prompt,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      Text(
        recallUnit.answer,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                controller.submitAnswer(
                  const RecallStudyAnswer(isRemembered: false),
                );
                controller.next();
              },
              child: Text(l10n.flashcardsStudyRecallMissedLabel),
            ),
          ),
          const SizedBox(width: FlashcardStudySessionTokens.bottomActionGap),
          Expanded(
            child: FilledButton(
              onPressed: () {
                controller.submitAnswer(
                  const RecallStudyAnswer(isRemembered: true),
                );
                controller.next();
              },
              child: Text(l10n.flashcardsStudyRecallRememberedLabel),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _renderFillUnit({
  required BuildContext context,
  required StudyUnit unit,
  required StudySessionController controller,
  required AppLocalizations l10n,
  required TextEditingController fillController,
}) {
  final FillUnit fillUnit = unit as FillUnit;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(
        fillUnit.prompt,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      AppTextField(
        controller: fillController,
        label: l10n.flashcardsStudyFillInputLabel,
        hint: l10n.flashcardsStudyFillInputHint,
      ),
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      FilledButton(
        onPressed: () {
          final String normalizedAnswer = StringUtils.normalize(
            fillController.text,
          );
          if (normalizedAnswer.isEmpty) {
            return;
          }
          controller.submitAnswer(FillStudyAnswer(text: normalizedAnswer));
          controller.next();
          fillController.clear();
        },
        child: Text(l10n.flashcardsStudySubmitLabel),
      ),
    ],
  );
}

Widget _renderMatchUnit({
  required BuildContext context,
  required StudyUnit unit,
  required StudySessionController controller,
  required AppLocalizations l10n,
  required TextEditingController fillController,
}) {
  final MatchUnit matchUnit = unit as MatchUnit;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(
        l10n.flashcardsStudyMatchPrompt,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: _MatchColumn(
              title: l10n.flashcardsStudyMatchLeftColumnLabel,
              entries: matchUnit.leftEntries,
              selectedId: matchUnit.selectedLeftId,
              matchedIds: matchUnit.matchedIds,
              onPressed: (entryId) {
                controller.submitAnswer(
                  MatchSelectLeftStudyAnswer(leftId: entryId),
                );
              },
            ),
          ),
          const SizedBox(width: FlashcardStudySessionTokens.sectionSpacing),
          Expanded(
            child: _MatchColumn(
              title: l10n.flashcardsStudyMatchRightColumnLabel,
              entries: matchUnit.rightEntries,
              selectedId: matchUnit.selectedRightId,
              matchedIds: matchUnit.matchedIds,
              onPressed: (entryId) {
                controller.submitAnswer(
                  MatchSelectRightStudyAnswer(rightId: entryId),
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
}

class _MatchColumn extends StatelessWidget {
  const _MatchColumn({
    required this.title,
    required this.entries,
    required this.selectedId,
    required this.matchedIds,
    required this.onPressed,
  });

  final String title;
  final List<MatchEntry> entries;
  final int? selectedId;
  final Set<int> matchedIds;
  final ValueChanged<int> onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        ...entries.map((entry) {
          final bool isMatched = matchedIds.contains(entry.id);
          final bool isSelected = selectedId == entry.id;
          return Padding(
            padding: const EdgeInsets.only(
              bottom: FlashcardStudySessionTokens.modeTileGap,
            ),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: _resolveMatchButtonBackground(
                  colorScheme: colorScheme,
                  isMatched: isMatched,
                  isSelected: isSelected,
                ),
              ),
              onPressed: isMatched ? null : () => onPressed(entry.id),
              child: Text(
                entry.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ],
    );
  }

  Color? _resolveMatchButtonBackground({
    required ColorScheme colorScheme,
    required bool isMatched,
    required bool isSelected,
  }) {
    if (isMatched) {
      return colorScheme.primaryContainer;
    }
    if (isSelected) {
      return colorScheme.secondaryContainer;
    }
    return null;
  }
}

String _resolveModeLabel({
  required StudyMode mode,
  required AppLocalizations l10n,
}) {
  final _ModeLabelResolver? resolver = _modeLabelRegistry[mode];
  if (resolver == null) {
    return mode.name;
  }
  return resolver(l10n);
}

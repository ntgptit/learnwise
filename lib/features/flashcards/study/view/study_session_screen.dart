import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../model/study_mode.dart';
import '../model/study_session_args.dart';
import '../model/study_unit.dart';
import '../viewmodel/study_session_viewmodel.dart';
import 'widgets/fill_study_mode_view.dart';
import 'widgets/guess_study_mode_view.dart';
import 'widgets/match_study_mode_view.dart';
import 'widgets/recall_study_mode_view.dart';
import 'widgets/review_study_mode_view.dart';

// quality-guard: allow-long-function
typedef _ModeLabelResolver = String Function(AppLocalizations l10n);

final Map<StudyMode, _ModeLabelResolver> _modeLabelRegistry =
    <StudyMode, _ModeLabelResolver>{
      StudyMode.review: (l10n) => l10n.flashcardsStudyModeReview,
      StudyMode.match: (l10n) => l10n.flashcardsStudyModeMatch,
      StudyMode.guess: (l10n) => l10n.flashcardsStudyModeGuess,
      StudyMode.recall: (l10n) => l10n.flashcardsStudyModeRecall,
      StudyMode.fill: (l10n) => l10n.flashcardsStudyModeFill,
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
  late final ProviderSubscription<int> _indexSubscription;

  @override
  void initState() {
    super.initState();
    _fillController = TextEditingController();
    _indexSubscription = ref.listenManual<int>(
      studySessionControllerProvider(
        widget.args,
      ).select((value) => value.currentIndex),
      (previous, next) {
        if (previous == next) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fillController.clear();
        });
      },
    );
  }

  @override
  void dispose() {
    _indexSubscription.close();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final provider = studySessionControllerProvider(widget.args);
    final StudyMode mode = ref.watch(provider.select((value) => value.mode));
    final String modeLabel = _resolveModeLabel(mode: mode, l10n: l10n);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: mode != StudyMode.review,
        title: Text(modeLabel, style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          onPressed: () => context.pop(true),
          tooltip: l10n.flashcardsBackTooltip,
          iconSize: FlashcardStudySessionTokens.iconSize,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: _buildAppBarActions(
          context: context,
          l10n: l10n,
          provider: provider,
          mode: mode,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            FlashcardStudySessionTokens.screenPadding,
          ),
          child: _StudySessionBody(
            provider: provider,
            l10n: l10n,
            fillController: _fillController,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions({
    required BuildContext context,
    required AppLocalizations l10n,
    required StudySessionControllerProvider provider,
    required StudyMode mode,
  }) {
    if (mode != StudyMode.review) {
      return const <Widget>[];
    }
    return <Widget>[
      IconButton(
        onPressed: () => _showToast(l10n.flashcardsStudyTextScaleToast),
        tooltip: l10n.flashcardsStudyTextScaleTooltip,
        iconSize: FlashcardStudySessionTokens.iconSize,
        icon: const Icon(Icons.text_fields_rounded),
      ),
      Consumer(
        builder: (context, ref, child) {
          final bool isPlayingAudio = ref.watch(
            provider.select((value) => value.playingFlashcardId != null),
          );
          final StudySessionController controller = ref.read(provider.notifier);
          final String frontText = _resolveCurrentReviewFrontText(
            ref,
            provider,
          );
          return IconButton(
            isSelected: isPlayingAudio,
            onPressed: () {
              controller.playCurrentAudio();
              if (frontText.isEmpty) {
                return;
              }
              _showToast(l10n.flashcardsAudioPlayToast(frontText));
            },
            tooltip: l10n.flashcardsPlayAudioTooltip,
            iconSize: FlashcardStudySessionTokens.iconSize,
            icon: const Icon(Icons.volume_up_outlined),
            selectedIcon: const Icon(Icons.graphic_eq_rounded),
          );
        },
      ),
      PopupMenuButton<String>(
        tooltip: l10n.flashcardsMoreActionsTooltip,
        itemBuilder: (context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'settings',
            child: Text(l10n.flashcardsFlipStudySettingsTooltip),
          ),
        ],
        onSelected: (value) {
          if (value != 'settings') {
            return;
          }
          _showToast(l10n.flashcardsFlipStudySettingsToast);
        },
      ),
    ];
  }

  String _resolveCurrentReviewFrontText(
    WidgetRef ref,
    StudySessionControllerProvider provider,
  ) {
    final StudyUnit? currentUnit = ref.read(provider).currentUnit;
    if (currentUnit is! ReviewUnit) {
      return '';
    }
    return currentUnit.frontText;
  }

  void _showToast(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _StudySessionBody extends ConsumerWidget {
  const _StudySessionBody({
    required this.provider,
    required this.l10n,
    required this.fillController,
  });

  final StudySessionControllerProvider provider;
  final AppLocalizations l10n;
  final TextEditingController fillController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudySessionState state = ref.watch(provider);
    final StudySessionController controller = ref.read(provider.notifier);

    if (state.totalCount <= 0) {
      return EmptyState(
        title: l10n.flashcardsEmptyTitle,
        subtitle: l10n.flashcardsEmptyDescription,
        icon: Icons.style_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _StudyProgressHeader(state: state),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Expanded(
          child: _StudyUnitBody(
            state: state,
            controller: controller,
            l10n: l10n,
            fillController: fillController,
          ),
        ),
      ],
    );
  }
}

class _StudyUnitBody extends StatelessWidget {
  const _StudyUnitBody({
    required this.state,
    required this.controller,
    required this.l10n,
    required this.fillController,
  });

  final StudySessionState state;
  final StudySessionController controller;
  final AppLocalizations l10n;
  final TextEditingController fillController;

  @override
  Widget build(BuildContext context) {
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
    final Widget unitContent = _buildUnitContent(currentUnit);
    final Widget content = AppCard(
      variant: AppCardVariant.elevated,
      elevation: FlashcardStudySessionTokens.cardElevation,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(
        FlashcardStudySessionTokens.cardRadius,
      ),
      padding: const EdgeInsets.all(FlashcardStudySessionTokens.cardPadding),
      child: unitContent,
    );
    if (state.mode == StudyMode.review) {
      return content;
    }
    return SingleChildScrollView(child: content);
  }

  Widget _buildUnitContent(StudyUnit currentUnit) {
    if (currentUnit is ReviewUnit) {
      return ReviewStudyModeView(
        unit: currentUnit,
        state: state,
        controller: controller,
        l10n: l10n,
      );
    }
    if (currentUnit is GuessUnit) {
      return GuessStudyModeView(
        unit: currentUnit,
        controller: controller,
        l10n: l10n,
      );
    }
    if (currentUnit is RecallUnit) {
      return RecallStudyModeView(
        unit: currentUnit,
        controller: controller,
        l10n: l10n,
      );
    }
    if (currentUnit is FillUnit) {
      return FillStudyModeView(
        unit: currentUnit,
        controller: controller,
        l10n: l10n,
        fillController: fillController,
      );
    }
    if (currentUnit is MatchUnit) {
      return MatchStudyModeView(
        unit: currentUnit,
        controller: controller,
        l10n: l10n,
      );
    }
    return const SizedBox.shrink();
  }
}

class _StudyProgressHeader extends StatelessWidget {
  const _StudyProgressHeader({required this.state});

  final StudySessionState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${state.currentStep} / ${state.totalCount}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(
            FlashcardStudySessionTokens.progressRadius,
          ),
          child: LinearProgressIndicator(
            value: state.progressPercent,
            minHeight: FlashcardStudySessionTokens.progressHeight,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
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
        borderRadius: BorderRadius.circular(
          FlashcardStudySessionTokens.cardRadius,
        ),
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

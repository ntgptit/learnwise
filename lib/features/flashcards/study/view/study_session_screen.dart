import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../app/router/route_names.dart';
import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../model/study_answer.dart';
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
typedef _ModeAppBarActionsBuilder =
    List<Widget> Function({
      required BuildContext context,
      required AppLocalizations l10n,
      required StudySessionControllerProvider provider,
    });
typedef _UnitContentLayoutBuilder =
    Widget Function(BuildContext context, Widget unitContent);

final Map<StudyMode, _ModeLabelResolver> _modeLabelRegistry =
    <StudyMode, _ModeLabelResolver>{
      StudyMode.review: (l10n) => l10n.flashcardsStudyModeReview,
      StudyMode.match: (l10n) => l10n.flashcardsStudyModeMatch,
      StudyMode.guess: (l10n) => l10n.flashcardsStudyModeGuess,
      StudyMode.recall: (l10n) => l10n.flashcardsStudyModeRecall,
      StudyMode.fill: (l10n) => l10n.flashcardsStudyModeFill,
    };

const Set<StudyMode> _leftAlignedTitleModes = <StudyMode>{StudyMode.review};

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
        centerTitle: _resolveCenterTitle(mode),
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
            studyArgs: widget.args,
            onNextModePressed: (mode) {
              _onNextModePressed(provider: provider, mode: mode);
            },
            onClosePressed: () {
              _onClosePressed(provider: provider);
            },
          ),
        ),
      ),
    );
  }

  void _onNextModePressed({
    required StudySessionControllerProvider provider,
    required StudyMode mode,
  }) {
    final StudySessionController controller = ref.read(provider.notifier);
    unawaited(controller.completeCurrentMode());
    final StudySessionArgs nextArgs = _buildNextCycleArgs(mode: mode);
    context.pushReplacement(RouteNames.flashcardStudySession, extra: nextArgs);
  }

  void _onClosePressed({
    required StudySessionControllerProvider provider,
  }) {
    final StudySessionController controller = ref.read(provider.notifier);
    unawaited(controller.completeCurrentMode());
    context.pop(true);
  }

  StudySessionArgs _buildNextCycleArgs({required StudyMode mode}) {
    final List<StudyMode> cycleModes = _resolveCycleModes(args: widget.args);
    final int currentIndex = _resolveCycleModeIndex(
      args: widget.args,
      cycleModes: cycleModes,
    );
    return widget.args.copyWith(
      mode: mode,
      cycleModes: cycleModes,
      cycleModeIndex: currentIndex + 1,
      forceReset: false,
    );
  }

  List<Widget> _buildAppBarActions({
    required BuildContext context,
    required AppLocalizations l10n,
    required StudySessionControllerProvider provider,
    required StudyMode mode,
  }) {
    final Map<StudyMode, _ModeAppBarActionsBuilder> registry =
        <StudyMode, _ModeAppBarActionsBuilder>{
          StudyMode.review: _buildReviewAppBarActions,
        };
    final _ModeAppBarActionsBuilder? builder = registry[mode];
    if (builder == null) {
      return const <Widget>[];
    }
    return builder(context: context, l10n: l10n, provider: provider);
  }

  List<Widget> _buildReviewAppBarActions({
    required BuildContext context,
    required AppLocalizations l10n,
    required StudySessionControllerProvider provider,
  }) {
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

  bool _resolveCenterTitle(StudyMode mode) {
    return !_leftAlignedTitleModes.contains(mode);
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
    required this.studyArgs,
    required this.onNextModePressed,
    required this.onClosePressed,
  });

  final StudySessionControllerProvider provider;
  final AppLocalizations l10n;
  final TextEditingController fillController;
  final StudySessionArgs studyArgs;
  final ValueChanged<StudyMode> onNextModePressed;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEmpty = ref.watch(
      provider.select((value) => value.totalCount <= 0),
    );

    if (isEmpty) {
      return EmptyState(
        title: l10n.flashcardsEmptyTitle,
        subtitle: l10n.flashcardsEmptyDescription,
        icon: Icons.style_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _StudyProgressHeader(provider: provider, studyArgs: studyArgs, l10n: l10n),
        const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
        Expanded(
          child: _StudyUnitBody(
            provider: provider,
            l10n: l10n,
            fillController: fillController,
            studyArgs: studyArgs,
            onNextModePressed: onNextModePressed,
            onClosePressed: onClosePressed,
          ),
        ),
      ],
    );
  }
}

class _StudyUnitBody extends ConsumerWidget {
  const _StudyUnitBody({
    required this.provider,
    required this.l10n,
    required this.fillController,
    required this.studyArgs,
    required this.onNextModePressed,
    required this.onClosePressed,
  });

  final StudySessionControllerProvider provider;
  final AppLocalizations l10n;
  final TextEditingController fillController;
  final StudySessionArgs studyArgs;
  final ValueChanged<StudyMode> onNextModePressed;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudySessionState state = ref.watch(provider);
    final StudySessionController controller = ref.read(provider.notifier);
    if (state.isCompleted) {
      final StudyMode? nextMode = _resolveNextCycleMode(
        args: studyArgs,
        state: state,
      );
      final String? nextModeLabel = _resolveNextModeLabel(
        l10n: l10n,
        nextMode: nextMode,
      );
      return _StudyCompletedCard(
        state: state,
        l10n: l10n,
        onRestartPressed: controller.restart,
        onNextModePressed: nextMode == null
            ? null
            : () => onNextModePressed(nextMode),
        nextModeLabel: nextModeLabel,
        onClosePressed: onClosePressed,
      );
    }
    final StudyUnit? currentUnit = state.currentUnit;
    if (currentUnit == null) {
      return const SizedBox.shrink();
    }
    final Widget unitContent = _buildUnitContent(
      currentUnit: currentUnit,
      state: state,
      controller: controller,
    );
    final _UnitContentLayoutBuilder layoutBuilder = _resolveLayoutBuilder(
      state.mode,
    );
    return layoutBuilder(context, unitContent);
  }

  Widget _buildUnitContent({
    required StudyUnit currentUnit,
    required StudySessionState state,
    required StudySessionController controller,
  }) {
    if (currentUnit is ReviewUnit) {
      return ReviewStudyModeView(
        units: state.reviewUnits,
        currentIndex: state.currentIndex,
        playingFlashcardId: state.playingFlashcardId,
        onPageChanged: controller.goTo,
        onAudioPressedFor: controller.playAudioFor,
        onNext: controller.next,
        onPrevious: controller.previous,
        l10n: l10n,
      );
    }
    if (currentUnit is GuessUnit) {
      return GuessStudyModeView(
        unit: currentUnit,
        onOptionSelected: (optionId) {
          controller.submitAnswer(GuessStudyAnswer(optionId: optionId));
          controller.next();
        },
      );
    }
    if (currentUnit is RecallUnit) {
      return RecallStudyModeView(
        unit: currentUnit,
        onMissedPressed: () {
          controller.submitAnswer(const RecallStudyAnswer(isRemembered: false));
          controller.next();
        },
        onRememberedPressed: () {
          controller.submitAnswer(const RecallStudyAnswer(isRemembered: true));
          controller.next();
        },
        l10n: l10n,
      );
    }
    if (currentUnit is FillUnit) {
      return FillStudyModeView(
        unit: currentUnit,
        onSubmitAnswer: (answer) {
          controller.submitAnswer(FillStudyAnswer(text: answer));
          controller.next();
        },
        l10n: l10n,
        fillController: fillController,
      );
    }
    if (currentUnit is MatchUnit) {
      return MatchStudyModeView(
        unit: currentUnit,
        state: state,
        onLeftPressed: (leftId) {
          controller.submitAnswer(MatchSelectLeftStudyAnswer(leftId: leftId));
        },
        onRightPressed: (rightId) {
          controller.submitAnswer(
            MatchSelectRightStudyAnswer(rightId: rightId),
          );
        },
        l10n: l10n,
      );
    }
    return const SizedBox.shrink();
  }

  _UnitContentLayoutBuilder _resolveLayoutBuilder(StudyMode mode) {
    final Map<StudyMode, _UnitContentLayoutBuilder> registry =
        <StudyMode, _UnitContentLayoutBuilder>{
          StudyMode.review: _buildDirectContentLayout,
          StudyMode.match: _buildDirectContentLayout,
        };
    final _UnitContentLayoutBuilder? builder = registry[mode];
    if (builder == null) {
      return _buildCardContentLayout;
    }
    return builder;
  }

  Widget _buildDirectContentLayout(BuildContext context, Widget unitContent) {
    return unitContent;
  }

  Widget _buildCardContentLayout(BuildContext context, Widget unitContent) {
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
    return SingleChildScrollView(child: content);
  }

  String? _resolveNextModeLabel({
    required AppLocalizations l10n,
    required StudyMode? nextMode,
  }) {
    if (nextMode == null) {
      return null;
    }
    final String modeLabel = _resolveModeLabel(mode: nextMode, l10n: l10n);
    return l10n.flashcardsStudyNextModeLabel(modeLabel);
  }
}

class _StudyProgressHeader extends ConsumerWidget {
  const _StudyProgressHeader({
    required this.provider,
    required this.studyArgs,
    required this.l10n,
  });

  final StudySessionControllerProvider provider;
  final StudySessionArgs studyArgs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudyMode mode = ref.watch(provider.select((value) => value.mode));
    final double progressPercent = ref.watch(
      provider.select((value) => value.progressPercent),
    );
    final int currentStep = ref.watch(
      provider.select((value) => value.currentStep),
    );
    final int totalCount = ref.watch(
      provider.select((value) => value.totalCount),
    );
    final int completedModeCount = ref.watch(
      provider.select((value) => value.completedModeCount),
    );
    final int requiredModeCount = ref.watch(
      provider.select((value) => value.requiredModeCount),
    );
    final Widget Function(BuildContext context) builder = _resolveBuilder(
      mode: mode,
      progressPercent: progressPercent,
      currentStep: currentStep,
      totalCount: totalCount,
    );
    final List<StudyMode> cycleModes = _resolveCycleModes(args: studyArgs);
    final int cycleModeIndex = _resolveCycleModeIndex(
      args: studyArgs,
      cycleModes: cycleModes,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        builder(context),
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        Text(
          l10n.flashcardsStudyCycleProgressLabel(
            completedModeCount,
            requiredModeCount,
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        Text(
          _buildCycleDisplayText(
            cycleModes: cycleModes,
            cycleModeIndex: cycleModeIndex,
            completedModeCount: completedModeCount,
            l10n: l10n,
          ),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget Function(BuildContext context) _resolveBuilder({
    required StudyMode mode,
    required double progressPercent,
    required int currentStep,
    required int totalCount,
  }) {
    final Map<StudyMode, Widget Function(BuildContext context)> registry =
        <StudyMode, Widget Function(BuildContext context)>{
          StudyMode.review: (context) {
            return _buildCompactProgressHeader(
              context: context,
              progressPercent: progressPercent,
            );
          },
          StudyMode.match: (context) {
            return _buildCompactProgressHeader(
              context: context,
              progressPercent: progressPercent,
            );
          },
        };
    final Widget Function(BuildContext context)? builder = registry[mode];
    if (builder == null) {
      return (context) {
        return _buildStandardProgressHeader(
          context: context,
          progressPercent: progressPercent,
          currentStep: currentStep,
          totalCount: totalCount,
        );
      };
    }
    return builder;
  }

  Widget _buildCompactProgressHeader({
    required BuildContext context,
    required double progressPercent,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String progressLabel = '${(progressPercent * 100).round()}%';
    return Row(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              FlashcardStudySessionTokens.progressRadius,
            ),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: FlashcardStudySessionTokens.progressHeight,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(width: FlashcardStudySessionTokens.bottomActionGap),
        Text(
          progressLabel,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildStandardProgressHeader({
    required BuildContext context,
    required double progressPercent,
    required int currentStep,
    required int totalCount,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '$currentStep / $totalCount',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
        ClipRRect(
          borderRadius: BorderRadius.circular(
            FlashcardStudySessionTokens.progressRadius,
          ),
          child: LinearProgressIndicator(
            value: progressPercent,
            minHeight: FlashcardStudySessionTokens.progressHeight,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }

  String _buildCycleDisplayText({
    required List<StudyMode> cycleModes,
    required int cycleModeIndex,
    required int completedModeCount,
    required AppLocalizations l10n,
  }) {
    final List<String> parts = <String>[];
    int index = 0;
    while (index < cycleModes.length) {
      final StudyMode mode = cycleModes[index];
      final String label = _resolveModeLabel(mode: mode, l10n: l10n);
      final String marker = _resolveCycleMarker(
        index: index,
        cycleModeIndex: cycleModeIndex,
        completedModeCount: completedModeCount,
      );
      parts.add('$marker $label');
      index++;
    }
    return parts.join(' -> ');
  }

  String _resolveCycleMarker({
    required int index,
    required int cycleModeIndex,
    required int completedModeCount,
  }) {
    if (index < completedModeCount) {
      return '[x]';
    }
    if (index == cycleModeIndex) {
      return '[>]';
    }
    return '[ ]';
  }
}

class _StudyCompletedCard extends StatelessWidget {
  const _StudyCompletedCard({
    required this.state,
    required this.l10n,
    required this.onRestartPressed,
    required this.onClosePressed,
    this.onNextModePressed,
    this.nextModeLabel,
  });

  final StudySessionState state;
  final AppLocalizations l10n;
  final VoidCallback onRestartPressed;
  final VoidCallback onClosePressed;
  final VoidCallback? onNextModePressed;
  final String? nextModeLabel;

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
            const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
            Text(
              l10n.flashcardsStudyCycleProgressLabel(
                state.completedModeCount,
                state.requiredModeCount,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
            if (onNextModePressed != null && nextModeLabel != null)
              FilledButton(
                onPressed: onNextModePressed,
                child: Text(nextModeLabel!),
              ),
            if (onNextModePressed != null && nextModeLabel != null)
              const SizedBox(
                height: FlashcardStudySessionTokens.answerSpacing,
              ),
            FilledButton(
              onPressed: onRestartPressed,
              child: Text(l10n.flashcardsStudyRestartLabel),
            ),
            const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
            OutlinedButton(
              onPressed: onClosePressed,
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

List<StudyMode> _resolveCycleModes({required StudySessionArgs args}) {
  if (args.cycleModes.isNotEmpty) {
    return args.cycleModes;
  }
  return buildStudyModeCycle(startMode: args.mode);
}

int _resolveCycleModeIndex({
  required StudySessionArgs args,
  required List<StudyMode> cycleModes,
}) {
  final int rawIndex = args.cycleModeIndex;
  if (rawIndex >= 0 && rawIndex < cycleModes.length) {
    return rawIndex;
  }
  final int modeIndex = cycleModes.indexOf(args.mode);
  if (modeIndex >= 0) {
    return modeIndex;
  }
  return 0;
}

StudyMode? _resolveNextCycleMode({
  required StudySessionArgs args,
  required StudySessionState state,
}) {
  if (state.isSessionCompleted) {
    return null;
  }
  final List<StudyMode> cycleModes = _resolveCycleModes(args: args);
  final int currentIndex = _resolveCycleModeIndex(
    args: args,
    cycleModes: cycleModes,
  );
  final int nextIndex = currentIndex + 1;
  if (nextIndex >= cycleModes.length) {
    return null;
  }
  return cycleModes[nextIndex];
}

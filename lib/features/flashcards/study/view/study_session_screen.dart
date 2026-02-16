import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/semantic_colors.dart';
import '../../../../common/styles/app_screen_tokens.dart';
import '../../../../common/widgets/widgets.dart';
import '../model/study_answer.dart';
import '../model/study_constants.dart';
import '../model/study_cycle_progress.dart';
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
              unawaited(_onNextModePressed(provider: provider, mode: mode));
            },
            onClosePressed: () {
              unawaited(_onClosePressed(provider: provider));
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onNextModePressed({
    required StudySessionControllerProvider provider,
    required StudyMode mode,
  }) async {
    final StudySessionController controller = ref.read(provider.notifier);
    await controller.completeCurrentMode();
    if (!mounted) {
      return;
    }
    final StudySessionArgs nextArgs = _buildNextCycleArgs(mode: mode);
    context.pushReplacement(RouteNames.flashcardStudySession, extra: nextArgs);
  }

  Future<void> _onClosePressed({
    required StudySessionControllerProvider provider,
  }) async {
    final StudySessionController controller = ref.read(provider.notifier);
    await controller.completeCurrentMode();
    if (!mounted) {
      return;
    }
    context.pop(true);
  }

  StudySessionArgs _buildNextCycleArgs({required StudyMode mode}) {
    final List<StudyMode> cycleModes = resolveStudyCycleModes(
      args: widget.args,
    );
    final int modeIndex = cycleModes.indexOf(mode);
    final int nextCycleIndex = modeIndex < 0 ? 0 : modeIndex;
    return widget.args.copyWith(
      mode: mode,
      cycleModes: cycleModes,
      cycleModeIndex: nextCycleIndex,
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
    final StudyMode mode = ref.watch(provider.select((value) => value.mode));
    final double headerToContentGap = _resolveHeaderToContentGap(mode);

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
        _StudyProgressHeader(
          provider: provider,
          studyArgs: studyArgs,
          l10n: l10n,
        ),
        SizedBox(height: headerToContentGap),
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

  double _resolveHeaderToContentGap(StudyMode mode) {
    if (mode == StudyMode.fill) {
      return FlashcardStudySessionTokens.fillHeaderToContentGap;
    }
    return FlashcardStudySessionTokens.sectionSpacing;
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
    final int displayedCompletedModeCount = resolveDisplayedCompletedModeCount(
      args: studyArgs,
      completedModeCount: state.completedModeCount,
      requiredModeCount: state.requiredModeCount,
      isModeCompleted: state.isCompleted,
      isSessionCompleted: state.isSessionCompleted,
      currentMode: state.mode,
    );
    if (state.isCompleted) {
      final List<StudyMode> cycleModes = resolveStudyCycleModes(
        args: studyArgs,
      );
      final StudyMode? nextMode = resolveNextCycleMode(
        args: studyArgs,
        currentMode: state.mode,
        completedModeCount: state.completedModeCount,
        requiredModeCount: state.requiredModeCount,
        isModeCompleted: state.isCompleted,
        isSessionCompleted: state.isSessionCompleted,
      );
      final String? nextModeLabel = _resolveNextModeLabel(
        l10n: l10n,
        nextMode: nextMode,
      );
      return _StudyCompletedCard(
        state: state,
        displayedCompletedModeCount: displayedCompletedModeCount,
        cycleModes: cycleModes,
        l10n: l10n,
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
        feedbackState: state.guessInteractionFeedback,
        onOptionSelected: (optionId) {
          controller.submitGuessOption(optionId);
        },
      );
    }
    if (currentUnit is RecallUnit) {
      return RecallStudyModeView(
        key: ValueKey<int>(state.currentIndex),
        unit: currentUnit,
        onMissedPressed: () {
          controller.submitRecallEvaluation(isRemembered: false);
        },
        onRememberedPressed: () {
          controller.submitRecallEvaluation(isRemembered: true);
        },
        l10n: l10n,
      );
    }
    if (currentUnit is FillUnit) {
      return FillStudyModeView(
        unit: currentUnit,
        onSubmitAnswer: (answer) {
          controller.submitFillAnswer(answer);
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
          StudyMode.guess: _buildDirectContentLayout,
          StudyMode.recall: _buildDirectContentLayout,
          StudyMode.fill: _buildDirectContentLayout,
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
    final int completedModeCount = ref.watch(
      provider.select((value) => value.completedModeCount),
    );
    final int requiredModeCount = ref.watch(
      provider.select((value) => value.requiredModeCount),
    );
    final bool isModeCompleted = ref.watch(
      provider.select((value) => value.isCompleted),
    );
    final bool isSessionCompleted = ref.watch(
      provider.select((value) => value.isSessionCompleted),
    );
    final int displayedCompletedModeCount = resolveDisplayedCompletedModeCount(
      args: studyArgs,
      completedModeCount: completedModeCount,
      requiredModeCount: requiredModeCount,
      isModeCompleted: isModeCompleted,
      isSessionCompleted: isSessionCompleted,
      currentMode: mode,
    );
    final Widget Function(BuildContext context) builder = _resolveBuilder(
      mode: mode,
      progressPercent: progressPercent,
    );
    final double progressToModeGap = _resolveProgressToModeGap(mode);
    final List<StudyMode> cycleModes = resolveStudyCycleModes(args: studyArgs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        builder(context),
        SizedBox(height: progressToModeGap),
        _StudyCycleModeProgress(
          cycleModes: cycleModes,
          completedModeCount: displayedCompletedModeCount,
          l10n: l10n,
        ),
      ],
    );
  }

  double _resolveProgressToModeGap(StudyMode mode) {
    if (mode == StudyMode.fill) {
      return FlashcardStudySessionTokens.fillProgressToModeGap;
    }
    return FlashcardStudySessionTokens.answerSpacing;
  }

  Widget Function(BuildContext context) _resolveBuilder({
    required StudyMode mode,
    required double progressPercent,
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
        return _buildCompactProgressHeader(
          context: context,
          progressPercent: progressPercent,
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
}

class _StudyCycleModeProgress extends StatelessWidget {
  const _StudyCycleModeProgress({
    required this.cycleModes,
    required this.completedModeCount,
    required this.l10n,
  });

  final List<StudyMode> cycleModes;
  final int completedModeCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (cycleModes.isEmpty) {
      return const SizedBox.shrink();
    }
    final int normalizedCompletedCount = completedModeCount.clamp(
      0,
      cycleModes.length,
    );
    final int focusIndex = _resolveFocusIndex(
      completedModeCount: normalizedCompletedCount,
      totalModeCount: cycleModes.length,
    );
    final List<Widget> children = <Widget>[];
    int index = 0;
    while (index < cycleModes.length) {
      if (index > StudyConstants.defaultIndex) {
        children.add(
          const SizedBox(
            width: FlashcardStudySessionTokens.cycleProgressItemGap,
          ),
        );
      }
      final StudyMode mode = cycleModes[index];
      children.add(
        Expanded(
          child: _buildModeTile(
            context: context,
            mode: mode,
            index: index,
            completedModeCount: normalizedCompletedCount,
            focusIndex: focusIndex,
          ),
        ),
      );
      index++;
    }
    return Row(children: children);
  }

  int _resolveFocusIndex({
    required int completedModeCount,
    required int totalModeCount,
  }) {
    if (completedModeCount >= totalModeCount) {
      return totalModeCount - 1;
    }
    return completedModeCount;
  }

  Widget _buildModeTile({
    required BuildContext context,
    required StudyMode mode,
    required int index,
    required int completedModeCount,
    required int focusIndex,
  }) {
    final bool isCompleted = index < completedModeCount;
    final bool isCurrent = !isCompleted && index == focusIndex;
    final _CycleModeTileStyle style = _resolveTileStyle(
      context: context,
      isCompleted: isCompleted,
      isCurrent: isCurrent,
    );
    final IconData modeIcon = _resolveModeIcon(mode);
    final IconData statusIcon = _resolveStatusIcon(
      isCompleted: isCompleted,
      isCurrent: isCurrent,
    );
    final String modeLabel = _resolveModeLabel(mode: mode, l10n: l10n);
    return Semantics(
      label: modeLabel,
      child: Tooltip(
        message: modeLabel,
        child: Container(
          height: FlashcardStudySessionTokens.cycleProgressItemHeight,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(
              FlashcardStudySessionTokens.cycleProgressItemRadius,
            ),
            border: Border.all(color: style.borderColor),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                modeIcon,
                size: FlashcardStudySessionTokens.cycleProgressIconSize,
                color: style.foregroundColor,
              ),
              const SizedBox(width: FlashcardStudySessionTokens.modeTileGap),
              Icon(
                statusIcon,
                size: FlashcardStudySessionTokens.cycleProgressStatusIconSize,
                color: style.statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CycleModeTileStyle _resolveTileStyle({
    required BuildContext context,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (isCompleted) {
      return _CycleModeTileStyle(
        backgroundColor: colorScheme.successContainer,
        borderColor: colorScheme.successContainer,
        foregroundColor: colorScheme.onSuccessContainer,
        statusColor: colorScheme.onSuccessContainer,
      );
    }
    if (isCurrent) {
      return _CycleModeTileStyle(
        backgroundColor: colorScheme.secondaryContainer,
        borderColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondaryContainer,
        statusColor: colorScheme.secondary,
      );
    }
    return _CycleModeTileStyle(
      backgroundColor: colorScheme.surfaceContainerHighest,
      borderColor: colorScheme.outlineVariant,
      foregroundColor: colorScheme.onSurfaceVariant,
      statusColor: colorScheme.onSurfaceVariant,
    );
  }

  IconData _resolveModeIcon(StudyMode mode) {
    if (mode == StudyMode.review) {
      return Icons.visibility_outlined;
    }
    if (mode == StudyMode.match) {
      return Icons.join_inner_rounded;
    }
    if (mode == StudyMode.guess) {
      return Icons.help_outline_rounded;
    }
    if (mode == StudyMode.recall) {
      return Icons.psychology_alt_outlined;
    }
    return Icons.edit_note_rounded;
  }

  IconData _resolveStatusIcon({
    required bool isCompleted,
    required bool isCurrent,
  }) {
    if (isCompleted) {
      return Icons.check_rounded;
    }
    if (isCurrent) {
      return Icons.circle_rounded;
    }
    return Icons.circle_outlined;
  }
}

class _CycleModeTileStyle {
  const _CycleModeTileStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.statusColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color statusColor;
}

class _StudyCompletedCard extends StatelessWidget {
  const _StudyCompletedCard({
    required this.state,
    required this.displayedCompletedModeCount,
    required this.cycleModes,
    required this.l10n,
    required this.onClosePressed,
    this.onNextModePressed,
    this.nextModeLabel,
  });

  final StudySessionState state;
  final int displayedCompletedModeCount;
  final List<StudyMode> cycleModes;
  final AppLocalizations l10n;
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
            _StudyCycleModeProgress(
              cycleModes: cycleModes,
              completedModeCount: displayedCompletedModeCount,
              l10n: l10n,
            ),
            const SizedBox(height: FlashcardStudySessionTokens.sectionSpacing),
            if (onNextModePressed != null && nextModeLabel != null)
              _buildCompletedActionButtonContainer(
                child: FilledButton(
                  onPressed: onNextModePressed,
                  child: Text(nextModeLabel!),
                ),
              ),
            if (onNextModePressed != null && nextModeLabel != null)
              const SizedBox(height: FlashcardStudySessionTokens.answerSpacing),
            _buildCompletedActionButtonContainer(
              child: OutlinedButton(
                onPressed: onClosePressed,
                child: Text(l10n.flashcardsCloseTooltip),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedActionButtonContainer({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double resolvedWidth =
            FlashcardStudySessionTokens.completedActionButtonWidth;
        if (constraints.maxWidth < resolvedWidth) {
          resolvedWidth = constraints.maxWidth;
        }
        return Align(
          alignment: Alignment.center,
          child: SizedBox(width: resolvedWidth, child: child),
        );
      },
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

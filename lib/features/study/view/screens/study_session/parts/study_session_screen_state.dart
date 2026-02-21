// quality-guard: allow-long-function
part of '../study_session_screen.dart';

Widget _buildStudySessionScreen({
  required BuildContext context,
  required WidgetRef ref,
  required StudySessionArgs args,
}) {
  final TextEditingController fillController = useTextEditingController();
  final ObjectRef<String?> lastAutoPlaySignatureRef = useRef<String?>(null);
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final ColorScheme colorScheme = Theme.of(context).colorScheme;
  final StudySessionControllerProvider provider =
      studySessionControllerProvider(args);
  final StudyMode mode = ref.watch(provider.select((value) => value.mode));
  final StudyModeContentBuilder? modeContentBuilder =
      _resolveModeContentBuilder(mode);
  final String modeLabel =
      modeContentBuilder?.resolveModeLabel(l10n) ?? mode.name;

  useEffect(() {
    final ProviderSubscription<int> indexSubscription = ref.listenManual<int>(
      provider.select((value) => value.currentIndex),
      (previous, next) {
        if (previous == next) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fillController.clear();
        });
      },
    );
    final ProviderSubscription<StudySessionState> autoPlaySubscription = ref
        .listenManual<StudySessionState>(provider, (previous, next) {
          unawaited(
            _onStudyStateChanged(
              ref: ref,
              args: args,
              lastAutoPlaySignatureRef: lastAutoPlaySignatureRef,
              previous: previous,
              next: next,
            ),
          );
        });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final StudySessionState initialState = ref.read(provider);
      unawaited(
        _attemptAutoPlay(
          ref: ref,
          args: args,
          lastAutoPlaySignatureRef: lastAutoPlaySignatureRef,
          state: initialState,
        ),
      );
    });
    return () {
      indexSubscription.close();
      autoPlaySubscription.close();
    };
  }, <Object>[provider, args.deckId]);

  return Scaffold(
    backgroundColor: colorScheme.surface,
    appBar: AppBar(
      centerTitle: modeContentBuilder?.centerTitle ?? true,
      title: Text(modeLabel, style: Theme.of(context).textTheme.titleLarge),
      leading: LwIconButton(
        onPressed: () => context.pop(true),
        tooltip: l10n.flashcardsBackTooltip,
        icon: Icons.arrow_back_rounded,
      ),
      actions: _buildStudySessionAppBarActions(
        context: context,
        l10n: l10n,
        provider: provider,
        modeContentBuilder: modeContentBuilder,
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
          fillController: fillController,
          studyArgs: args,
          onNextModePressed: (nextMode) {
            unawaited(
              _onNextModePressed(
                context: context,
                ref: ref,
                args: args,
                provider: provider,
                mode: nextMode,
              ),
            );
          },
          onClosePressed: () {
            unawaited(
              _onClosePressed(context: context, ref: ref, provider: provider),
            );
          },
        ),
      ),
    ),
  );
}

Future<void> _onNextModePressed({
  required BuildContext context,
  required WidgetRef ref,
  required StudySessionArgs args,
  required StudySessionControllerProvider provider,
  required StudyMode mode,
}) async {
  final StudySessionController controller = ref.read(provider.notifier);
  await controller.completeCurrentMode();
  final StudySessionArgs nextArgs = _buildNextCycleArgs(args: args, mode: mode);
  final FlashcardStudySessionRoute route = FlashcardStudySessionRoute(
    $extra: nextArgs,
  );
  // ignore: use_build_context_synchronously
  context.pushReplacement(route.location, extra: route.$extra);
}

Future<void> _onClosePressed({
  required BuildContext context,
  required WidgetRef ref,
  required StudySessionControllerProvider provider,
}) async {
  final StudySessionController controller = ref.read(provider.notifier);
  await controller.completeCurrentMode();
  // ignore: use_build_context_synchronously
  context.pop(true);
}

StudySessionArgs _buildNextCycleArgs({
  required StudySessionArgs args,
  required StudyMode mode,
}) {
  final List<StudyMode> cycleModes = resolveStudyCycleModes(args: args);
  final int modeIndex = cycleModes.indexOf(mode);
  final int nextCycleIndex = modeIndex < 0 ? 0 : modeIndex;
  return args.copyWith(
    mode: mode,
    cycleModes: cycleModes,
    cycleModeIndex: nextCycleIndex,
    forceReset: false,
  );
}

List<Widget> _buildStudySessionAppBarActions({
  required BuildContext context,
  required AppLocalizations l10n,
  required StudySessionControllerProvider provider,
  required StudyModeContentBuilder? modeContentBuilder,
}) {
  if (modeContentBuilder == null) {
    return const <Widget>[];
  }
  final ModeAppBarActionBuildContext appBarContext =
      ModeAppBarActionBuildContext(
        context: context,
        l10n: l10n,
        provider: provider,
        showToast: (message) {
          final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
            context,
          );
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
      );
  return modeContentBuilder.buildAppBarActions(appBarContext);
}

Future<void> _onStudyStateChanged({
  required WidgetRef ref,
  required StudySessionArgs args,
  required ObjectRef<String?> lastAutoPlaySignatureRef,
  required StudySessionState? previous,
  required StudySessionState next,
}) async {
  if (_isManualAudioRequested(previous: previous, next: next)) {
    await _speakCurrentUnit(
      ref: ref,
      args: args,
      lastAutoPlaySignatureRef: lastAutoPlaySignatureRef,
      state: next,
      bypassDedup: true,
    );
    return;
  }
  await _attemptAutoPlay(
    ref: ref,
    args: args,
    lastAutoPlaySignatureRef: lastAutoPlaySignatureRef,
    state: next,
  );
}

bool _isManualAudioRequested({
  required StudySessionState? previous,
  required StudySessionState next,
}) {
  final int? nextPlayingFlashcardId = next.playingFlashcardId;
  if (nextPlayingFlashcardId == null) {
    return false;
  }
  final int? previousPlayingFlashcardId = previous?.playingFlashcardId;
  if (previousPlayingFlashcardId == nextPlayingFlashcardId) {
    return false;
  }
  return true;
}

Future<void> _attemptAutoPlay({
  required WidgetRef ref,
  required StudySessionArgs args,
  required ObjectRef<String?> lastAutoPlaySignatureRef,
  required StudySessionState state,
}) async {
  if (!_isStudyAutoPlayEnabled(ref: ref, args: args)) {
    lastAutoPlaySignatureRef.value = null;
    return;
  }
  await _speakCurrentUnit(
    ref: ref,
    args: args,
    lastAutoPlaySignatureRef: lastAutoPlaySignatureRef,
    state: state,
    bypassDedup: false,
  );
}

Future<void> _speakCurrentUnit({
  required WidgetRef ref,
  required StudySessionArgs args,
  required ObjectRef<String?> lastAutoPlaySignatureRef,
  required StudySessionState state,
  required bool bypassDedup,
}) async {
  final String text = _resolvePronunciationText(state.currentUnit);
  if (text.isEmpty) {
    return;
  }
  final String signature = _buildAutoPlaySignature(state: state, text: text);
  if (!bypassDedup && lastAutoPlaySignatureRef.value == signature) {
    return;
  }
  lastAutoPlaySignatureRef.value = signature;
  final TtsController ttsController = ref.read(ttsControllerProvider.notifier);
  _applyTtsSettings(ref: ref, args: args, ttsController: ttsController);
  await ttsController.initialize();
  await ttsController.speakText(text);
}

bool _isStudyAutoPlayEnabled({
  required WidgetRef ref,
  required StudySessionArgs args,
}) {
  final UserStudySettings settings = ref.read(
    effectiveStudySettingsForDeckProvider(args.deckId),
  );
  return settings.studyAutoPlayAudio;
}

void _applyTtsSettings({
  required WidgetRef ref,
  required StudySessionArgs args,
  required TtsController ttsController,
}) {
  final UserStudySettings settings = ref.read(
    effectiveStudySettingsForDeckProvider(args.deckId),
  );
  ttsController.applyVoiceSettings(
    voiceId: settings.ttsVoiceId,
    speechRate: settings.ttsSpeechRate,
    pitch: settings.ttsPitch,
    volume: settings.ttsVolume,
    clearVoiceId: settings.ttsVoiceId == null,
  );
}

String _buildAutoPlaySignature({
  required StudySessionState state,
  required String text,
}) {
  final StudyUnit? unit = state.currentUnit;
  final String unitId = unit?.unitId ?? '';
  final String modeName = state.mode.name;
  final int index = state.currentIndex;
  return '$modeName|$index|$unitId|$text';
}

String _resolvePronunciationText(StudyUnit? unit) {
  if (unit == null) {
    return '';
  }
  if (unit is ReviewUnit) {
    return StringUtils.normalize(unit.frontText);
  }
  if (unit is GuessUnit) {
    return StringUtils.normalize(unit.prompt);
  }
  if (unit is RecallUnit) {
    return StringUtils.normalize(unit.prompt);
  }
  if (unit is FillUnit) {
    return StringUtils.normalize(unit.expectedAnswer);
  }
  if (unit is MatchUnit) {
    return _resolveMatchPronunciationText(unit);
  }
  return '';
}

String _resolveMatchPronunciationText(MatchUnit unit) {
  for (final MatchEntry entry in unit.leftEntries) {
    if (unit.matchedIds.contains(entry.id)) {
      continue;
    }
    return StringUtils.normalize(entry.label);
  }
  return '';
}

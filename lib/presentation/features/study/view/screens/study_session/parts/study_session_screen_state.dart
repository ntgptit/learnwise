// quality-guard: allow-long-function
part of '../study_session_screen.dart';

class _FlashcardStudySessionScreenState
    extends ConsumerState<FlashcardStudySessionScreen> {
  late final TextEditingController _fillController;
  late final ProviderSubscription<int> _indexSubscription;
  late final ProviderSubscription<StudySessionState> _autoPlaySubscription;
  String? _lastAutoPlaySignature;

  @override
  void initState() {
    super.initState();
    final StudySessionControllerProvider provider =
        studySessionControllerProvider(widget.args);
    _fillController = TextEditingController();
    _indexSubscription = ref.listenManual<int>(
      provider.select((value) => value.currentIndex),
      (previous, next) {
        if (previous == next) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fillController.clear();
        });
      },
    );
    _autoPlaySubscription = ref.listenManual<StudySessionState>(provider, (
      previous,
      next,
    ) {
      unawaited(_onStudyStateChanged(previous: previous, next: next));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final StudySessionState initialState = ref.read(provider);
      unawaited(_attemptAutoPlay(state: initialState));
    });
  }

  @override
  void dispose() {
    _indexSubscription.close();
    _autoPlaySubscription.close();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final provider = studySessionControllerProvider(widget.args);
    final StudyMode mode = ref.watch(provider.select((value) => value.mode));
    final StudyModeContentBuilder? modeContentBuilder =
        _resolveModeContentBuilder(mode);
    final String modeLabel =
        modeContentBuilder?.resolveModeLabel(l10n) ?? mode.name;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: modeContentBuilder?.centerTitle ?? true,
        title: Text(modeLabel, style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          onPressed: () => context.pop(true),
          tooltip: l10n.flashcardsBackTooltip,
          iconSize: FlashcardStudySessionTokens.iconSize,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: _buildAppBarActions(
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
    final StudySessionArgs nextArgs = _buildNextCycleArgs(mode: mode);
    final FlashcardStudySessionRoute route = FlashcardStudySessionRoute(
      $extra: nextArgs,
    );
    // ignore: use_build_context_synchronously
    context.pushReplacement(route.location, extra: route.$extra);
  }

  Future<void> _onClosePressed({
    required StudySessionControllerProvider provider,
  }) async {
    final StudySessionController controller = ref.read(provider.notifier);
    await controller.completeCurrentMode();
    // ignore: use_build_context_synchronously
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
          showToast: _showToast,
        );
    return modeContentBuilder.buildAppBarActions(appBarContext);
  }

  void _showToast(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onStudyStateChanged({
    required StudySessionState? previous,
    required StudySessionState next,
  }) async {
    if (_isManualAudioRequested(previous: previous, next: next)) {
      await _speakCurrentUnit(state: next, bypassDedup: true);
      return;
    }
    await _attemptAutoPlay(state: next);
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

  Future<void> _attemptAutoPlay({required StudySessionState state}) async {
    if (!_isStudyAutoPlayEnabled()) {
      _lastAutoPlaySignature = null;
      return;
    }
    await _speakCurrentUnit(state: state, bypassDedup: false);
  }

  Future<void> _speakCurrentUnit({
    required StudySessionState state,
    required bool bypassDedup,
  }) async {
    final String text = _resolvePronunciationText(state.currentUnit);
    if (text.isEmpty) {
      return;
    }
    final String signature = _buildAutoPlaySignature(state: state, text: text);
    if (!bypassDedup && _lastAutoPlaySignature == signature) {
      return;
    }
    _lastAutoPlaySignature = signature;
    final TtsController ttsController = ref.read(
      ttsControllerProvider.notifier,
    );
    _applyTtsSettings(ttsController);
    await ttsController.initialize();
    await ttsController.speakText(text);
  }

  bool _isStudyAutoPlayEnabled() {
    final UserStudySettings settings = ref.read(
      effectiveStudySettingsForDeckProvider(widget.args.deckId),
    );
    return settings.studyAutoPlayAudio;
  }

  void _applyTtsSettings(TtsController ttsController) {
    final UserStudySettings settings = ref.read(
      effectiveStudySettingsForDeckProvider(widget.args.deckId),
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
}

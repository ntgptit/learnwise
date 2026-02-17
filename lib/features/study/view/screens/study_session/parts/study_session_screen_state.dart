// quality-guard: allow-long-function
part of '../study_session_screen.dart';

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
    final GoRouter router = GoRouter.of(context);
    final StudySessionController controller = ref.read(provider.notifier);
    await controller.completeCurrentMode();
    final StudySessionArgs nextArgs = _buildNextCycleArgs(mode: mode);
    router.pushReplacement(RouteNames.flashcardStudySession, extra: nextArgs);
  }

  Future<void> _onClosePressed({
    required StudySessionControllerProvider provider,
  }) async {
    final GoRouter router = GoRouter.of(context);
    final StudySessionController controller = ref.read(provider.notifier);
    await controller.completeCurrentMode();
    router.pop(true);
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
}

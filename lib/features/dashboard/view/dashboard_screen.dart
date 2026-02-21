import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../model/dashboard_constants.dart';
import '../model/dashboard_models.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import 'widgets/dashboard_sections.dart';

class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  @override
  // quality-guard: allow-long-function - dashboard template wiring centralizes hooks + state mapping and page callbacks.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<DashboardSnapshot> state = ref.watch(
      dashboardControllerProvider,
    );
    final DashboardController controller = ref.read(
      dashboardControllerProvider.notifier,
    );
    final ScrollController scrollController = useScrollController();
    final LwPageContentState contentState = _resolveContentState(state);
    final DashboardSnapshot? snapshot = _resolveSnapshot(state);
    final VoidCallback onRefresh = useCallback(() {
      _refresh(controller);
    }, <Object?>[controller]);
    final VoidCallback onRefreshAndScrollToTop = useCallback(() {
      _refreshAndScrollToTop(
        controller: controller,
        scrollController: scrollController,
      );
    }, <Object?>[controller, scrollController]);
    final VoidCallback onOpenSettings = useCallback(() {
      _openProfileSettings(context);
    }, <Object?>[context]);

    return LwPageTemplate(
      title: l10n.dashboardTitle,
      body: _DashboardBody(snapshot: snapshot),
      selectedIndex: DashboardConstants.dashboardNavIndex,
      contentState: contentState,
      loadingMessage: l10n.dashboardLoadingLabel,
      errorTitle: l10n.dashboardErrorTitle,
      errorMessage: l10n.dashboardErrorDescription,
      errorRetryLabel: l10n.dashboardRetryLabel,
      contentPadding: const EdgeInsets.all(
        DashboardScreenTokens.contentPadding,
      ),
      useBodyScrollView: true,
      scrollController: scrollController,
      onRefresh: onRefresh,
      onRetry: onRefresh,
      onRefreshAndScrollToTop: onRefreshAndScrollToTop,
      onOpenSettings: onOpenSettings,
      onDestinationSelected: (index) {
        _onDestinationSelected(context: context, index: index);
      },
    );
  }

  void _onDestinationSelected({
    required BuildContext context,
    required int index,
  }) {
    final StatefulNavigationShellState navigationShell =
        StatefulNavigationShell.of(context);
    if (index == navigationShell.currentIndex) {
      return;
    }
    navigationShell.goBranch(index);
  }

  LwPageContentState _resolveContentState(AsyncValue<DashboardSnapshot> state) {
    return state.when(
      data: (_) => LwPageContentState.content,
      error: (error, stackTrace) => LwPageContentState.error,
      loading: () => LwPageContentState.loading,
    );
  }

  DashboardSnapshot? _resolveSnapshot(AsyncValue<DashboardSnapshot> state) {
    return state.when(
      data: (snapshot) => snapshot,
      error: (error, stackTrace) => null,
      loading: () => null,
    );
  }

  void _refresh(DashboardController controller) {
    unawaited(controller.refresh());
  }

  void _refreshAndScrollToTop({
    required DashboardController controller,
    required ScrollController scrollController,
  }) {
    if (scrollController.hasClients) {
      unawaited(
        scrollController.animateTo(
          0,
          duration: AppDurations.animationFast,
          curve: AppMotionCurves.decelerateCubic,
        ),
      );
    }
    _refresh(controller);
  }

  void _openProfileSettings(BuildContext context) {
    final StatefulNavigationShellState navigationShell =
        StatefulNavigationShell.of(context);
    navigationShell.goBranch(DashboardConstants.profileNavIndex);
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.snapshot});

  final DashboardSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final DashboardSnapshot? resolvedSnapshot = snapshot;
    if (resolvedSnapshot == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buildDashboardSectionItems(snapshot: resolvedSnapshot),
    );
  }
}

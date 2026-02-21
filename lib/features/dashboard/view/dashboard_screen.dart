import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/widgets/widgets.dart';
import '../model/dashboard_constants.dart';
import '../model/dashboard_models.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import 'widgets/dashboard_sections.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<DashboardSnapshot> state = ref.watch(
      dashboardControllerProvider,
    );
    final DashboardController controller = ref.read(
      dashboardControllerProvider.notifier,
    );

    return LwPageTemplate(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: _DashboardBody(l10n: l10n, state: state, controller: controller),
      selectedIndex: DashboardConstants.dashboardNavIndex,
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
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.l10n,
    required this.state,
    required this.controller,
  });

  final AppLocalizations l10n;
  final AsyncValue<DashboardSnapshot> state;
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: state.when(
        data: (snapshot) => _buildData(context, snapshot),
        error: (error, stackTrace) => _buildError(),
        loading: _buildLoading,
      ),
    );
  }

  Widget _buildData(BuildContext context, DashboardSnapshot snapshot) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        // quality-guard: allow-list-children - bounded dashboard sections (non-feed).
        padding: const EdgeInsets.all(DashboardScreenTokens.contentPadding),
        children: buildDashboardSectionItems(
          context: context,
          snapshot: snapshot,
        ),
      ),
    );
  }

  Widget _buildError() {
    return LwErrorState(
      title: l10n.dashboardErrorTitle,
      message: l10n.dashboardErrorDescription,
      retryLabel: l10n.dashboardRetryLabel,
      onRetry: controller.refresh,
    );
  }

  Widget _buildLoading() {
    return LwLoadingState(message: l10n.dashboardLoadingLabel);
  }
}

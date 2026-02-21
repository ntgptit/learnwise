import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'page_template_contract.dart';

class LwPageTemplate extends StatelessWidget {
  const LwPageTemplate({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.useSafeArea = false,
    this.resizeToAvoidBottomInset,
    this.onRefresh,
    this.onRetry,
    this.onTapBack,
    this.onTapClose,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onClearSearch,
    this.onFilterChanged,
    this.onSortChanged,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.onOpenHelp,
    this.onOpenSettings,
    this.onEmptyAction,
    this.onLoadMore,
    this.onRefreshAndScrollToTop,
    this.onViewModeChanged,
    this.onToggleSelectionMode,
    this.onBulkAction,
    this.onShowMessage,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool useSafeArea;
  final bool? resizeToAvoidBottomInset;

  // Must-have callbacks.
  final VoidCallback? onRefresh;
  final VoidCallback? onRetry;
  final VoidCallback? onTapBack;
  final VoidCallback? onTapClose;

  // Very common callbacks.
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onClearSearch;
  final ValueChanged<LwFilterState>? onFilterChanged;
  final ValueChanged<LwSortOption>? onSortChanged;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onEmptyAction;

  // Advanced callbacks.
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefreshAndScrollToTop;
  final ValueChanged<LwViewMode>? onViewModeChanged;
  final ValueChanged<bool>? onToggleSelectionMode;
  final ValueChanged<LwBulkAction>? onBulkAction;
  final ValueChanged<LwPageMessage>? onShowMessage;

  @override
  Widget build(BuildContext context) {
    return LwAppShell(
      appBar: appBar,
      body: body,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      useSafeArea: useSafeArea,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

// quality-guard: allow-large-file - central page template keeps shared UI contract and render states in one place.
// quality-guard: allow-large-class - single template class intentionally aggregates standardized page behaviors.
import 'package:flutter/material.dart';

import '../../styles/app_screen_tokens.dart';
import '../../styles/app_sizes.dart';
import '../buttons/icon_button.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';
import '../input/app_text_field.dart';
import '../state/empty_state.dart';
import '../state/error_state.dart';
import '../state/loading_state.dart';
import 'app_shell.dart';
import 'page_template_contract.dart';
import 'spaced_row.dart';

class LwPageTemplate extends StatelessWidget {
  const LwPageTemplate({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
    this.appBar,
    this.title,
    this.appBarLeadingAction = LwPageLeadingAction.automatic,
    this.appBarActions = const <LwPageActionIcon>[],
    this.secondaryActionBar,
    this.searchField,
    this.filterControl,
    this.sortControl,
    this.floatingActionButton,
    this.bottomPrimaryAction,
    this.backgroundColor,
    this.contentPadding,
    this.secondaryActionPadding,
    this.useSafeArea = false,
    this.resizeToAvoidBottomInset,
    this.useBodyScrollView = false,
    this.scrollController,
    this.contentState = LwPageContentState.content,
    this.loadingMessage,
    this.errorTitle,
    this.errorMessage,
    this.errorRetryLabel,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyIcon = Icons.inbox_rounded,
    this.emptyActionLabel,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.backTooltip,
    this.closeTooltip,
    this.searchHintText,
    this.clearSearchTooltip,
    this.helpTooltip,
    this.settingsTooltip,
    this.scrollToTopTooltip,
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
  final String? title;
  final LwPageLeadingAction appBarLeadingAction;
  final List<LwPageActionIcon> appBarActions;
  final Widget body;
  final Widget? secondaryActionBar;
  final Widget? searchField;
  final Widget? filterControl;
  final Widget? sortControl;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? floatingActionButton;
  final Widget? bottomPrimaryAction;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? secondaryActionPadding;
  final bool useSafeArea;
  final bool? resizeToAvoidBottomInset;
  final bool useBodyScrollView;
  final ScrollController? scrollController;
  final LwPageContentState contentState;
  final String? loadingMessage;
  final String? errorTitle;
  final String? errorMessage;
  final String? errorRetryLabel;
  final String? emptyTitle;
  final String? emptySubtitle;
  final IconData emptyIcon;
  final String? emptyActionLabel;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final String? backTooltip;
  final String? closeTooltip;
  final String? searchHintText;
  final String? clearSearchTooltip;
  final String? helpTooltip;
  final String? settingsTooltip;
  final String? scrollToTopTooltip;

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
    final PreferredSizeWidget? resolvedAppBar = _resolveAppBar();
    final Widget resolvedBody = _buildTemplateBody(context);
    final Widget? resolvedFab = _resolveFloatingActionButton();
    return LwAppShell(
      appBar: resolvedAppBar,
      body: resolvedBody,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      floatingActionButton: resolvedFab,
      backgroundColor: backgroundColor,
      useSafeArea: useSafeArea,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  PreferredSizeWidget? _resolveAppBar() {
    if (appBar != null) {
      return appBar;
    }
    if (!_hasStandardAppBar()) {
      return null;
    }
    return AppBar(
      title: title == null ? null : Text(title!),
      leading: _buildLeading(),
      actions: _buildAppBarActions(),
    );
  }

  bool _hasStandardAppBar() {
    if (title != null) {
      return true;
    }
    if (_resolveLeadingAction() != LwPageLeadingAction.none) {
      return true;
    }
    if (_buildAppBarActions().isNotEmpty) {
      return true;
    }
    return false;
  }

  LwPageLeadingAction _resolveLeadingAction() {
    if (appBarLeadingAction != LwPageLeadingAction.automatic) {
      return appBarLeadingAction;
    }
    if (onTapBack != null) {
      return LwPageLeadingAction.back;
    }
    if (onTapClose != null) {
      return LwPageLeadingAction.close;
    }
    return LwPageLeadingAction.none;
  }

  Widget? _buildLeading() {
    final LwPageLeadingAction leadingAction = _resolveLeadingAction();
    if (leadingAction == LwPageLeadingAction.none) {
      return null;
    }
    if (leadingAction == LwPageLeadingAction.back) {
      final VoidCallback? onPressed = onTapBack;
      if (onPressed == null) {
        return null;
      }
      return LwIconButton(
        icon: Icons.arrow_back_rounded,
        tooltip: backTooltip ?? _LwPageTemplateText.defaultBackTooltip,
        onPressed: onPressed,
      );
    }
    if (leadingAction == LwPageLeadingAction.close) {
      final VoidCallback? onPressed = onTapClose;
      if (onPressed == null) {
        return null;
      }
      return LwIconButton(
        icon: Icons.close_rounded,
        tooltip: closeTooltip ?? _LwPageTemplateText.defaultCloseTooltip,
        onPressed: onPressed,
      );
    }
    return null;
  }

  List<Widget> _buildAppBarActions() {
    final List<Widget> actions = <Widget>[];
    for (final LwPageActionIcon actionIcon in appBarActions) {
      actions.add(
        LwIconButton(
          icon: actionIcon.icon,
          tooltip: actionIcon.tooltip,
          onPressed: actionIcon.onPressed,
        ),
      );
    }
    if (onOpenHelp != null) {
      actions.add(
        LwIconButton(
          icon: Icons.help_outline_rounded,
          tooltip: helpTooltip ?? _LwPageTemplateText.defaultHelpTooltip,
          onPressed: onOpenHelp,
        ),
      );
    }
    if (onOpenSettings != null) {
      actions.add(
        LwIconButton(
          icon: Icons.settings_outlined,
          tooltip:
              settingsTooltip ?? _LwPageTemplateText.defaultSettingsTooltip,
          onPressed: onOpenSettings,
        ),
      );
    }
    if (onRefreshAndScrollToTop != null) {
      actions.add(
        LwIconButton(
          icon: Icons.vertical_align_top_rounded,
          tooltip:
              scrollToTopTooltip ??
              _LwPageTemplateText.defaultScrollToTopTooltip,
          onPressed: onRefreshAndScrollToTop,
        ),
      );
    }
    return actions;
  }

  Widget? _resolveFloatingActionButton() {
    if (floatingActionButton != null) {
      return floatingActionButton;
    }
    return null;
  }

  Widget _buildTemplateBody(BuildContext context) {
    // quality-guard: allow-long-function - body composition keeps state, secondary actions, and primary actions co-located.
    final Widget stateAwareBody = _buildStateAwareBody();
    final Widget paddedBody = Padding(
      padding:
          contentPadding ??
          const EdgeInsets.all(_LwPageTemplateTokens.defaultContentPadding),
      child: stateAwareBody,
    );
    final Widget scrollAwareBody = _buildScrollAwareBody(paddedBody);
    final Widget refreshAwareBody = _buildRefreshAwareBody(scrollAwareBody);
    final Widget? resolvedSecondaryBar = _buildSecondaryActionBar(context);
    final Widget? resolvedBottomAction = _buildBottomPrimaryAction();
    if (resolvedSecondaryBar == null && resolvedBottomAction == null) {
      return refreshAwareBody;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ...?resolvedSecondaryBar == null
            ? null
            : <Widget>[resolvedSecondaryBar],
        Expanded(child: refreshAwareBody),
        ...?resolvedBottomAction == null
            ? null
            : <Widget>[resolvedBottomAction],
      ],
    );
  }

  Widget _buildStateAwareBody() {
    if (contentState == LwPageContentState.loading) {
      return LwLoadingState(message: loadingMessage);
    }
    if (contentState == LwPageContentState.error) {
      return LwErrorState(
        title: errorTitle ?? _LwPageTemplateText.defaultErrorTitle,
        message: errorMessage,
        retryLabel: _resolveErrorRetryLabel(),
        onRetry: onRetry,
      );
    }
    if (contentState == LwPageContentState.empty) {
      return LwEmptyState(
        title: emptyTitle ?? _LwPageTemplateText.defaultEmptyTitle,
        subtitle: emptySubtitle,
        icon: emptyIcon,
        action: _buildEmptyAction(),
      );
    }
    return body;
  }

  String? _resolveErrorRetryLabel() {
    if (onRetry == null) {
      return null;
    }
    if (errorRetryLabel != null) {
      return errorRetryLabel;
    }
    return _LwPageTemplateText.defaultRetryLabel;
  }

  Widget? _buildEmptyAction() {
    if (onEmptyAction == null) {
      return null;
    }
    if (emptyActionLabel == null) {
      return null;
    }
    return LwPrimaryButton(
      label: emptyActionLabel!,
      expanded: false,
      onPressed: onEmptyAction,
    );
  }

  Widget _buildScrollAwareBody(Widget child) {
    if (!useBodyScrollView) {
      return child;
    }
    final Widget scrollView = SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: child,
    );
    if (onLoadMore == null) {
      return scrollView;
    }
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: scrollView,
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (onLoadMore == null) {
      return false;
    }
    if (notification.metrics.extentAfter >
        _LwPageTemplateTokens.loadMoreTriggerExtent) {
      return false;
    }
    if (notification is! ScrollEndNotification) {
      return false;
    }
    onLoadMore!.call();
    return false;
  }

  Widget _buildRefreshAwareBody(Widget child) {
    if (onRefresh == null) {
      return child;
    }
    if (!useBodyScrollView) {
      return child;
    }
    return RefreshIndicator(onRefresh: _handleRefresh, child: child);
  }

  Future<void> _handleRefresh() async {
    final VoidCallback? onRefreshCallback = onRefresh;
    if (onRefreshCallback == null) {
      return;
    }
    onRefreshCallback();
  }

  Widget? _buildSecondaryActionBar(BuildContext context) {
    final Widget? customSecondaryActionBar = secondaryActionBar;
    if (customSecondaryActionBar != null) {
      return _buildSecondaryActionContainer(
        context: context,
        child: customSecondaryActionBar,
      );
    }
    final Widget? resolvedSearchField = _buildSearchField();
    final Widget? resolvedFilterControl = _buildFilterControl();
    final Widget? resolvedSortControl = _buildSortControl();
    if (resolvedSearchField == null &&
        resolvedFilterControl == null &&
        resolvedSortControl == null) {
      return null;
    }
    final List<Widget> children = <Widget>[
      if (resolvedSearchField != null) Expanded(child: resolvedSearchField),
      ...?resolvedFilterControl == null
          ? null
          : <Widget>[resolvedFilterControl],
      ...?resolvedSortControl == null ? null : <Widget>[resolvedSortControl],
    ];
    return _buildSecondaryActionContainer(
      context: context,
      child: LwSpacedRow(
        spacing: _LwPageTemplateTokens.secondaryActionItemSpacing,
        children: children,
      ),
    );
  }

  Widget _buildSecondaryActionContainer({
    required BuildContext context,
    required Widget child,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding:
          secondaryActionPadding ??
          const EdgeInsets.fromLTRB(
            _LwPageTemplateTokens.defaultContentPadding,
            _LwPageTemplateTokens.secondaryActionTopPadding,
            _LwPageTemplateTokens.defaultContentPadding,
            _LwPageTemplateTokens.secondaryActionBottomPadding,
          ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(
            _LwPageTemplateTokens.secondaryActionRadius,
          ),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            _LwPageTemplateTokens.secondaryActionInnerPadding,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget? _buildSearchField() {
    if (searchField != null) {
      return searchField;
    }
    if (onSearchChanged == null &&
        onSearchSubmitted == null &&
        onClearSearch == null) {
      return null;
    }
    return LwTextField(
      hint: searchHintText ?? _LwPageTemplateText.defaultSearchHint,
      onChanged: onSearchChanged,
      onSubmitted: onSearchSubmitted,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: _buildSearchSuffixIcon(),
    );
  }

  Widget? _buildSearchSuffixIcon() {
    if (onClearSearch == null) {
      return null;
    }
    return LwIconButton(
      icon: Icons.close_rounded,
      tooltip: clearSearchTooltip ?? _LwPageTemplateText.defaultClearTooltip,
      onPressed: onClearSearch,
    );
  }

  Widget? _buildFilterControl() {
    if (filterControl != null) {
      return filterControl;
    }
    if (onFilterChanged == null) {
      return null;
    }
    return LwIconButton(
      icon: Icons.filter_alt_outlined,
      tooltip: _LwPageTemplateText.defaultFilterTooltip,
      onPressed: _onFilterPressed,
    );
  }

  Widget? _buildSortControl() {
    if (sortControl != null) {
      return sortControl;
    }
    if (onSortChanged == null) {
      return null;
    }
    return LwIconButton(
      icon: Icons.swap_vert_rounded,
      tooltip: _LwPageTemplateText.defaultSortTooltip,
      onPressed: _onSortPressed,
    );
  }

  void _onFilterPressed() {
    final ValueChanged<LwFilterState>? onFilterChangedCallback =
        onFilterChanged;
    if (onFilterChangedCallback == null) {
      return;
    }
    onFilterChangedCallback(const LwFilterState());
  }

  void _onSortPressed() {
    final ValueChanged<LwSortOption>? onSortChangedCallback = onSortChanged;
    if (onSortChangedCallback == null) {
      return;
    }
    onSortChangedCallback(
      const LwSortOption(field: _LwPageTemplateText.defaultSortField),
    );
  }

  Widget? _buildBottomPrimaryAction() {
    if (bottomPrimaryAction != null) {
      return _buildBottomActionContainer(bottomPrimaryAction!);
    }
    final Widget? actionRow = _buildDefaultBottomActionRow();
    if (actionRow == null) {
      return null;
    }
    return _buildBottomActionContainer(actionRow);
  }

  Widget? _buildDefaultBottomActionRow() {
    if (onPrimaryAction == null || primaryActionLabel == null) {
      return null;
    }
    final Widget primaryButton = LwPrimaryButton(
      label: primaryActionLabel!,
      onPressed: onPrimaryAction,
    );
    if (onSecondaryAction == null || secondaryActionLabel == null) {
      return primaryButton;
    }
    return LwSpacedRow(
      spacing: _LwPageTemplateTokens.bottomActionItemSpacing,
      children: <Widget>[
        Expanded(
          child: LwSecondaryButton(
            label: secondaryActionLabel!,
            onPressed: onSecondaryAction,
          ),
        ),
        Expanded(child: primaryButton),
      ],
    );
  }

  Widget _buildBottomActionContainer(Widget child) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _LwPageTemplateTokens.defaultContentPadding,
          _LwPageTemplateTokens.bottomActionTopPadding,
          _LwPageTemplateTokens.defaultContentPadding,
          _LwPageTemplateTokens.bottomActionBottomPadding,
        ),
        child: child,
      ),
    );
  }
}

class _LwPageTemplateTokens {
  const _LwPageTemplateTokens._();

  static const double defaultContentPadding = BaseScreenTokens.screenPadding;
  static const double secondaryActionTopPadding = AppSizes.spacingXs;
  static const double secondaryActionBottomPadding = AppSizes.spacingSm;
  static const double secondaryActionInnerPadding = AppSizes.spacingXs;
  static const double secondaryActionRadius = AppSizes.radiusMd;
  static const double secondaryActionItemSpacing = AppSizes.spacingXs;
  static const double bottomActionTopPadding = AppSizes.spacingSm;
  static const double bottomActionBottomPadding = AppSizes.spacingSm;
  static const double bottomActionItemSpacing = AppSizes.spacingSm;
  static const double loadMoreTriggerExtent = AppSizes.size72;
}

class _LwPageTemplateText {
  const _LwPageTemplateText._();

  static const String defaultBackTooltip = 'Back';
  static const String defaultCloseTooltip = 'Close';
  static const String defaultHelpTooltip = 'Help';
  static const String defaultSettingsTooltip = 'Settings';
  static const String defaultScrollToTopTooltip = 'Scroll to top';
  static const String defaultSearchHint = 'Search';
  static const String defaultClearTooltip = 'Clear';
  static const String defaultFilterTooltip = 'Filter';
  static const String defaultSortTooltip = 'Sort';
  static const String defaultSortField = 'default';
  static const String defaultErrorTitle = 'Something went wrong';
  static const String defaultRetryLabel = 'Try again';
  static const String defaultEmptyTitle = 'No data';
}

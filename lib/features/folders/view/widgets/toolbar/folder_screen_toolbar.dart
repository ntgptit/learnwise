part of '../../folder_screen.dart';

/// Modern toolbar combining search and sort controls.
class _FolderToolbar extends StatelessWidget {
  const _FolderToolbar({
    required this.searchController,
    required this.searchFocusNode,
    required this.searchHint,
    required this.sortTooltip,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onSortPressed,
    required this.onMenuActionSelected,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchHint;
  final String sortTooltip;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onClearSearch;
  final List<PopupMenuEntry<_FolderMenuAction>> Function(BuildContext)
  onSortPressed;
  final ValueChanged<_FolderMenuAction> onMenuActionSelected;

  @override
  // quality-guard: allow-long-function - search field and sort action remain together for a compact toolbar composition.
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderRadius buttonRadius = BorderRadius.circular(AppSizes.radiusMd);

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.size20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: LwSearchField(
              controller: searchController,
              focusNode: searchFocusNode,
              hint: searchHint,
              onChanged: onSearchChanged,
              onSubmitted: (_) => onSearchSubmitted(),
              onClear: onClearSearch,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: AppSizes.size44,
            height: AppSizes.size44,
            child: PopupMenuButton<_FolderMenuAction>(
              onSelected: onMenuActionSelected,
              itemBuilder: onSortPressed,
              tooltip: sortTooltip,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  colorScheme.surfaceContainerHighest,
                ),
                shape: WidgetStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(borderRadius: buttonRadius),
                ),
                elevation: const WidgetStatePropertyAll<double>(0),
              ),
              icon: Icon(
                Icons.tune_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateActionItem {
  const _CreateActionItem({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

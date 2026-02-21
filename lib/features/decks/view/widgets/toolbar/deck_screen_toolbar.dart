part of '../../deck_screen.dart';

class _DeckToolbar extends StatelessWidget {
  const _DeckToolbar({
    required this.searchController,
    required this.searchFocusNode,
    required this.searchHint,
    required this.sortTooltip,
    required this.query,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClearSearch,
    required this.onMenuActionSelected,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String searchHint;
  final String sortTooltip;
  final DeckListQuery query;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;
  final VoidCallback onClearSearch;
  final ValueChanged<_DeckMenuAction> onMenuActionSelected;

  @override
  // quality-guard: allow-long-function - toolbar keeps search and sort controls co-located for consistent deck-list interactions.
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final BorderRadius buttonRadius = BorderRadius.circular(AppSizes.radiusMd);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

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
          const SizedBox(width: AppSizes.spacingXs),
          SizedBox(
            width: AppSizes.size44,
            height: AppSizes.size44,
            child: PopupMenuButton<_DeckMenuAction>(
              onSelected: onMenuActionSelected,
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
              itemBuilder: (context) {
                return <PopupMenuEntry<_DeckMenuAction>>[
                  CheckedPopupMenuItem<_DeckMenuAction>(
                    value: _DeckMenuAction.sortByCreatedAt,
                    checked: query.sortBy == DeckSortBy.createdAt,
                    child: Text(l10n.foldersSortByCreatedAt),
                  ),
                  CheckedPopupMenuItem<_DeckMenuAction>(
                    value: _DeckMenuAction.sortByName,
                    checked: query.sortBy == DeckSortBy.name,
                    child: Text(l10n.foldersSortByName),
                  ),
                  const PopupMenuDivider(),
                  CheckedPopupMenuItem<_DeckMenuAction>(
                    value: _DeckMenuAction.sortDirectionDesc,
                    checked: query.sortDirection == DeckSortDirection.desc,
                    child: Text(l10n.foldersSortDirectionDesc),
                  ),
                  CheckedPopupMenuItem<_DeckMenuAction>(
                    value: _DeckMenuAction.sortDirectionAsc,
                    checked: query.sortDirection == DeckSortDirection.asc,
                    child: Text(l10n.foldersSortDirectionAsc),
                  ),
                ];
              },
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

class _DeckScreenTokens {
  const _DeckScreenTokens._();

  static const double sectionSpacing = AppSizes.spacingMd;
  static const double cardSpacing = AppSizes.spacingSm;
}

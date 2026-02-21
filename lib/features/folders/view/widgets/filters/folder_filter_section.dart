// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../model/folder_models.dart';

const int _sortDirectionDescIndex = 0;
const int _sortDirectionAscIndex = 1;

class FolderFilterSection extends StatelessWidget {
  const FolderFilterSection({
    required this.query,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onSortByChanged,
    required this.onSortDirectionChanged,
    super.key,
  });

  final FolderListQuery query;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchSubmitted;
  final ValueChanged<FolderSortBy> onSortByChanged;
  final ValueChanged<FolderSortDirection> onSortDirectionChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Set<int> selectedDirection = <int>{_resolveSelectedDirectionIndex()};

    return LwCard(
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.all(FolderScreenTokens.cardPadding),
      borderRadius: BorderRadius.circular(FolderScreenTokens.cardRadius),
      border: Border.all(
        color: Theme.of(
          context,
        ).colorScheme.outline.withValues(alpha: AppOpacities.outline26),
      ),
      child: LwSpacedColumn(
        spacing: FolderScreenTokens.sectionSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LwTextField(
            controller: searchController,
            onChanged: onSearchChanged,
            onSubmitted: (_) => onSearchSubmitted(),
            hint: l10n.foldersSearchHint,
            textInputAction: TextInputAction.search,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: onSearchSubmitted,
              tooltip: l10n.foldersSearchHint,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
          LwSelectBox<FolderSortBy>(
            value: query.sortBy,
            labelText: l10n.foldersSortByLabel,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              onSortByChanged(value);
            },
            options: <LwSelectOption<FolderSortBy>>[
              LwSelectOption<FolderSortBy>(
                value: FolderSortBy.createdAt,
                label: l10n.foldersSortByCreatedAt,
              ),
              LwSelectOption<FolderSortBy>(
                value: FolderSortBy.name,
                label: l10n.foldersSortByName,
              ),
              LwSelectOption<FolderSortBy>(
                value: FolderSortBy.flashcardCount,
                label: l10n.foldersSortByFlashcardCount,
              ),
            ],
          ),
          LwSegmentedControl(
            labels: <String>[
              l10n.foldersSortDirectionDesc,
              l10n.foldersSortDirectionAsc,
            ],
            selected: selectedDirection,
            onSelectionChanged: (values) {
              if (values.isEmpty) {
                return;
              }
              onSortDirectionChanged(_resolveSortDirection(values.first));
            },
          ),
        ],
      ),
    );
  }

  int _resolveSelectedDirectionIndex() {
    if (query.sortDirection == FolderSortDirection.asc) {
      return _sortDirectionAscIndex;
    }
    return _sortDirectionDescIndex;
  }

  FolderSortDirection _resolveSortDirection(int index) {
    if (index == _sortDirectionAscIndex) {
      return FolderSortDirection.asc;
    }
    return FolderSortDirection.desc;
  }
}

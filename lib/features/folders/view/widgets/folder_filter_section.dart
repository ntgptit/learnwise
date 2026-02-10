import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_screen_tokens.dart';
import '../../model/folder_models.dart';

class FolderFilterSection extends StatelessWidget {
  const FolderFilterSection({
    super.key,
    required this.query,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onSortByChanged,
    required this.onSortDirectionChanged,
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

    return Container(
      padding: const EdgeInsets.all(FolderScreenTokens.cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FolderScreenTokens.cardRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(
            alpha: FolderScreenTokens.outlineOpacity,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            onSubmitted: (_) => onSearchSubmitted(),
            decoration: InputDecoration(
              hintText: l10n.foldersSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: onSearchSubmitted,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
          ),
          const SizedBox(height: FolderScreenTokens.sectionSpacing),
          DropdownButtonFormField<FolderSortBy>(
            initialValue: query.sortBy,
            decoration: InputDecoration(labelText: l10n.foldersSortByLabel),
            onChanged: (FolderSortBy? value) {
              if (value == null) {
                return;
              }
              onSortByChanged(value);
            },
            items: <DropdownMenuItem<FolderSortBy>>[
              DropdownMenuItem<FolderSortBy>(
                value: FolderSortBy.createdAt,
                child: Text(l10n.foldersSortByCreatedAt),
              ),
              DropdownMenuItem<FolderSortBy>(
                value: FolderSortBy.name,
                child: Text(l10n.foldersSortByName),
              ),
              DropdownMenuItem<FolderSortBy>(
                value: FolderSortBy.flashcardCount,
                child: Text(l10n.foldersSortByFlashcardCount),
              ),
            ],
          ),
          const SizedBox(height: FolderScreenTokens.sectionSpacing),
          SegmentedButton<FolderSortDirection>(
            segments: <ButtonSegment<FolderSortDirection>>[
              ButtonSegment<FolderSortDirection>(
                value: FolderSortDirection.desc,
                label: Text(l10n.foldersSortDirectionDesc),
              ),
              ButtonSegment<FolderSortDirection>(
                value: FolderSortDirection.asc,
                label: Text(l10n.foldersSortDirectionAsc),
              ),
            ],
            selected: <FolderSortDirection>{query.sortDirection},
            onSelectionChanged: (Set<FolderSortDirection> values) {
              if (values.isEmpty) {
                return;
              }
              onSortDirectionChanged(values.first);
            },
          ),
        ],
      ),
    );
  }
}

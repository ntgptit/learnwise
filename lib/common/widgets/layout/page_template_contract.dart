import 'package:flutter/material.dart';

enum LwSortDirection { ascending, descending }

enum LwViewMode { list, grid, compact }

enum LwBulkAction { selectAll, clearSelection, deleteSelected, archiveSelected }

enum LwPageMessageLevel { info, success, warning, error }

enum LwPageContentState { content, loading, error, empty }

enum LwPageLeadingAction { automatic, none, back, close }

@immutable
class LwPageActionIcon {
  const LwPageActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
}

@immutable
class LwFilterState {
  const LwFilterState({
    this.keyword = '',
    this.criteria = const <String, Object?>{},
    this.tags = const <String>{},
  });

  final String keyword;
  final Map<String, Object?> criteria;
  final Set<String> tags;

  bool get hasActiveFilters {
    if (keyword.isNotEmpty) {
      return true;
    }
    if (criteria.isNotEmpty) {
      return true;
    }
    return tags.isNotEmpty;
  }
}

@immutable
class LwSortOption {
  const LwSortOption({
    required this.field,
    this.direction = LwSortDirection.ascending,
  });

  final String field;
  final LwSortDirection direction;
}

@immutable
class LwPageMessage {
  const LwPageMessage({
    required this.text,
    this.level = LwPageMessageLevel.info,
  });

  final String text;
  final LwPageMessageLevel level;
}

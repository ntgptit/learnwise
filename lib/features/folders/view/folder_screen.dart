import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_spacing.dart';
import '../../../common/styles/app_screen_tokens.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../decks/model/deck_models.dart';
import '../../decks/view/widgets/deck_editor_dialog.dart';
import '../../decks/view/widgets/deck_empty_state.dart';
import '../../decks/view/widgets/deck_list_card.dart';
import '../../decks/viewmodel/deck_viewmodel.dart';
import '../../flashcards/model/flashcard_management_args.dart';
import '../model/folder_constants.dart';
import '../model/folder_models.dart';
import '../viewmodel/folder_viewmodel.dart';
import 'widgets/cards/folder_list_card.dart';
import 'widgets/dialogs/folder_editor_dialog.dart';
import 'widgets/state/folder_empty_state.dart';

part 'screen/folder_screen_logic.dart';
part 'screen/folder_screen_build.dart';
part 'screen/folder_screen_build_body.dart';
part 'screen/folder_screen_logic_actions.dart';
part 'screen/folder_screen_logic_navigation.dart';
part 'screen/folder_screen_logic_state.dart';
part 'widgets/toolbar/folder_screen_toolbar.dart';

enum _FolderMenuAction {
  refresh,
  sortByCreatedAt,
  sortByName,
  sortByFlashcardCount,
  sortDirectionDesc,
  sortDirectionAsc,
}

class _FolderScreenHookState {
  const _FolderScreenHookState({
    required this.context,
    required this.ref,
    required this.searchController,
    required this.searchFocusNode,
    required this.scrollController,
    required this.hasSubfoldersByFolderIdRef,
    required this.searchDebounceTimerRef,
  });

  final BuildContext context;
  final WidgetRef ref;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ScrollController scrollController;
  final ObjectRef<Map<int, bool>> hasSubfoldersByFolderIdRef;
  final ObjectRef<Timer?> searchDebounceTimerRef;
}

class FolderScreen extends HookConsumerWidget {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildFolderScreen(context: context, ref: ref);
  }
}

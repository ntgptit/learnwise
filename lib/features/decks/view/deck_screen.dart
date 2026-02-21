import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../flashcards/model/flashcard_management_args.dart';
import '../../folders/model/folder_constants.dart';
import '../model/deck_constants.dart';
import '../model/deck_models.dart';
import '../viewmodel/deck_viewmodel.dart';
import 'widgets/deck_editor_dialog.dart';
import 'widgets/deck_empty_state.dart';
import 'widgets/deck_list_card.dart';

part 'screen/deck_screen_build.dart';
part 'screen/deck_screen_logic.dart';
part 'widgets/toolbar/deck_screen_toolbar.dart';

enum _DeckMenuAction {
  refresh,
  sortByCreatedAt,
  sortByName,
  sortDirectionDesc,
  sortDirectionAsc,
}

class DeckScreen extends HookConsumerWidget {
  const DeckScreen({required this.folderId, this.folderName = '', super.key});

  final int folderId;
  final String folderName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildDeckScreen(context: context, ref: ref);
  }
}

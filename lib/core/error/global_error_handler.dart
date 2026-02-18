// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../utils/string_utils.dart';
import 'app_error_bus.dart';
import 'error_code.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class GlobalErrorHandler extends ConsumerWidget {
  const GlobalErrorHandler({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    ref.listen<AppErrorEvent?>(appErrorBusProvider, (previous, next) {
      if (next == null || previous?.id == next.id) {
        return;
      }

      final String defaultMessage = switch (next.code) {
        AppErrorCode.ttsInitFailed => l10n.snackInitFailed,
        AppErrorCode.ttsLoadVoicesFailed => l10n.snackLoadVoicesFailed,
        AppErrorCode.ttsReadFailed => l10n.snackReadFailed,
        AppErrorCode.ttsStopFailed => l10n.snackStopFailed,
        AppErrorCode.badRequest => l10n.snackBadRequest,
        AppErrorCode.unauthorized => l10n.snackUnauthorized,
        AppErrorCode.forbidden => l10n.snackForbidden,
        AppErrorCode.notFound => l10n.snackNotFound,
        AppErrorCode.conflict => l10n.snackConflict,
        AppErrorCode.unprocessableEntity => l10n.snackUnprocessableEntity,
        AppErrorCode.tooManyRequests => l10n.snackTooManyRequests,
        AppErrorCode.serverError => l10n.snackServerError,
        AppErrorCode.networkUnavailable => l10n.snackNetworkUnavailable,
        AppErrorCode.timeout => l10n.snackTimeout,
        AppErrorCode.unexpectedResponse => l10n.snackUnexpectedResponse,
        AppErrorCode.dashboardLoadFailed => l10n.snackDashboardLoadFailed,
        AppErrorCode.folderLoadFailed => l10n.snackFolderLoadFailed,
        AppErrorCode.folderCreateFailed => l10n.snackFolderCreateFailed,
        AppErrorCode.folderUpdateFailed => l10n.snackFolderUpdateFailed,
        AppErrorCode.folderDeleteFailed => l10n.snackFolderDeleteFailed,
        AppErrorCode.folderRestoreFailed => l10n.snackFolderRestoreFailed,
        AppErrorCode.flashcardLoadFailed => l10n.snackFlashcardLoadFailed,
        AppErrorCode.flashcardCreateFailed => l10n.snackFlashcardCreateFailed,
        AppErrorCode.flashcardUpdateFailed => l10n.snackFlashcardUpdateFailed,
        AppErrorCode.flashcardDeleteFailed => l10n.snackFlashcardDeleteFailed,
        AppErrorCode.unknown => l10n.snackUnknownError,
      };
      final String message = _resolveMessage(
        customMessage: next.message,
        defaultMessage: defaultMessage,
      );

      final ScaffoldMessengerState? messenger =
          appScaffoldMessengerKey.currentState;
      if (messenger != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
      ref.read(appErrorBusProvider.notifier).consume(next.id);
    });

    return child;
  }

  String _resolveMessage({
    required String? customMessage,
    required String defaultMessage,
  }) {
    final String? normalized = StringUtils.normalizeNullable(customMessage);
    if (normalized == null) {
      return defaultMessage;
    }
    return normalized;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import 'app_error_bus.dart';
import 'error_code.dart';

class GlobalErrorHandler extends ConsumerWidget {
  const GlobalErrorHandler({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    ref.listen<AppErrorEvent?>(appErrorBusProvider, (
      AppErrorEvent? previous,
      AppErrorEvent? next,
    ) {
      if (next == null || previous?.id == next.id) {
        return;
      }

      final String message = switch (next.code) {
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
        AppErrorCode.unknown => l10n.snackUnknownError,
      };

      final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(
        context,
      );
      if (messenger != null) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
      ref.read(appErrorBusProvider.notifier).consume(next.id);
    });

    return child;
  }
}

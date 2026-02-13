import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/error/global_error_handler.dart';

void main() {
  runApp(const ProviderScope(child: LearnWiseApp()));
}

class LearnWiseApp extends StatelessWidget {
  const LearnWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return GlobalErrorHandler(child: child);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_mode_controller.dart';
import 'core/error/global_error_handler.dart';
import 'core/network/auth_session.dart';

void main() {
  runApp(const ProviderScope(child: LearnWiseApp()));
}

class LearnWiseApp extends StatelessWidget {
  const LearnWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LearnWiseAppView();
  }
}

class _LearnWiseAppView extends ConsumerWidget {
  const _LearnWiseAppView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final ThemeMode themeMode = ref.watch(appThemeModeControllerProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }
        return _AppActivityListener(child: GlobalErrorHandler(child: child));
      },
    );
  }
}

class _AppActivityListener extends ConsumerWidget {
  const _AppActivityListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        ref.read(authSessionManagerProvider).markUserActivity();
      },
      child: child,
    );
  }
}

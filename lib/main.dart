import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

// a11y-guard: allow-no-text-scaling - typography scale is intentionally clamped for compact layout.
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_mode_controller.dart';
import 'core/error/global_error_handler.dart';
import 'core/network/auth_session.dart';
// ignore: unused_import
import 'quality/reachability_manifest.dart';

const double minAppTextScaleFactor = 0.85;
const double maxAppTextScaleFactor = 1.0;

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
      builder: _buildRootChild,
    );
  }

  Widget _buildRootChild(BuildContext context, Widget? child) {
    if (child == null) {
      return const SizedBox.shrink();
    }
    final Widget normalizedScaleChild = _buildClampedTextScaleChild(
      context: context,
      child: child,
    );
    return _AppActivityListener(
      child: GlobalErrorHandler(child: normalizedScaleChild),
    );
  }

  Widget _buildClampedTextScaleChild({
    required BuildContext context,
    required Widget child,
  }) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double currentTextScaleFactor = mediaQueryData.textScaler.scale(1);
    final double clampedTextScaleFactor = currentTextScaleFactor
        .clamp(minAppTextScaleFactor, maxAppTextScaleFactor)
        .toDouble();
    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaler: TextScaler.linear(clampedTextScaleFactor),
      ),
      child: child,
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

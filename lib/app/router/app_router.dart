import 'package:flutter/material.dart';

import '../../features/dashboard/view/dashboard_screen.dart';
import '../../features/folders/view/folder_screen.dart';
import '../../features/tts/view/tts_screen.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static String get initialRoute => RouteNames.dashboard;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.root:
      case RouteNames.dashboard:
        return _material(settings: settings, child: const DashboardScreen());
      case RouteNames.folders:
        return _material(settings: settings, child: const FolderScreen());
      case RouteNames.tts:
        return _material(settings: settings, child: const TtsScreen());
      case RouteNames.login:
        return _material(
          settings: settings,
          child: const _StubScreen(title: _RouteText.login),
        );
      case RouteNames.learning:
        return _material(
          settings: settings,
          child: const _StubScreen(title: _RouteText.learning),
        );
      case RouteNames.progressDetail:
        return _material(
          settings: settings,
          child: const _StubScreen(title: _RouteText.progressDetail),
        );
      default:
        return _material(settings: settings, child: const _NotFoundScreen());
    }
  }

  static Route<dynamic> _material({
    required RouteSettings settings,
    required Widget child,
  }) {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => child);
  }
}

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title${_RouteText.notImplementedSuffix}')),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text(_RouteText.notFound)));
  }
}

class _RouteText {
  const _RouteText._();

  static const String login = 'Login';
  static const String learning = 'Learning';
  static const String progressDetail = 'Progress Detail';
  static const String notImplementedSuffix = ' screen is not implemented yet.';
  static const String notFound = 'Route not found.';
}

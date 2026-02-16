import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/auth_session.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/auth/view/register_screen.dart';
import '../../features/dashboard/view/dashboard_screen.dart';
import '../../features/flashcards/model/flashcard_management_args.dart';
import '../../features/flashcards/view/flashcard_flip_study_screen.dart';
import '../../features/flashcards/view/flashcard_management_screen.dart';
import '../../features/folders/view/folder_screen.dart';
import '../../features/study/model/study_session_args.dart';
import '../../features/study/view/index.dart';
import '../../features/tts/view/tts_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final AuthSessionManager authSessionManager = ref.read(
    authSessionManagerProvider,
  );

  return GoRouter(
    initialLocation: RouteNames.login,
    refreshListenable: authSessionManager,
    redirect: (context, state) {
      final String location = state.uri.path;
      final bool isAuthRoute =
          location == RouteNames.login || location == RouteNames.register;
      if (!authSessionManager.isReady) {
        if (isAuthRoute) {
          return null;
        }
        return RouteNames.login;
      }
      if (!authSessionManager.isAuthenticated && !isAuthRoute) {
        return RouteNames.login;
      }
      if (authSessionManager.isAuthenticated && isAuthRoute) {
        return RouteNames.dashboard;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.root,
        builder: (context, state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: RouteNames.folders,
        builder: (context, state) {
          return const FolderScreen();
        },
      ),
      GoRoute(
        path: RouteNames.flashcards,
        builder: (context, state) {
          final FlashcardManagementArgs args = _resolveFlashcardArgs(
            state.extra,
          );
          return FlashcardManagementScreen(args: args);
        },
      ),
      GoRoute(
        path: RouteNames.flashcardFlipStudy,
        builder: (context, state) {
          final FlashcardFlipStudyArgs args = _resolveFlipStudyArgs(
            state.extra,
          );
          return FlashcardFlipStudyScreen(
            items: args.items,
            initialIndex: args.initialIndex,
            title: args.title,
          );
        },
      ),
      GoRoute(
        path: RouteNames.flashcardStudySession,
        builder: (context, state) {
          final StudySessionArgs args = _resolveStudySessionArgs(state.extra);
          return FlashcardStudySessionScreen(args: args);
        },
      ),
      GoRoute(
        path: RouteNames.tts,
        builder: (context, state) {
          return const TtsScreen();
        },
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: RouteNames.learning,
        builder: (context, state) {
          return const _StubScreen(title: _RouteText.learning);
        },
      ),
      GoRoute(
        path: RouteNames.progressDetail,
        builder: (context, state) {
          return const _StubScreen(title: _RouteText.progressDetail);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return const _NotFoundScreen();
    },
  );
}

FlashcardManagementArgs _resolveFlashcardArgs(Object? extra) {
  if (extra is FlashcardManagementArgs) {
    return extra;
  }
  return const FlashcardManagementArgs.fallback();
}

FlashcardFlipStudyArgs _resolveFlipStudyArgs(Object? extra) {
  if (extra is FlashcardFlipStudyArgs) {
    return extra;
  }
  return const FlashcardFlipStudyArgs.fallback();
}

StudySessionArgs _resolveStudySessionArgs(Object? extra) {
  if (extra is StudySessionArgs) {
    return extra;
  }
  return const StudySessionArgs.fallback();
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

  static const String learning = 'Learning';
  static const String progressDetail = 'Progress Detail';
  static const String notImplementedSuffix = ' screen is not implemented yet.';
  static const String notFound = 'Route not found.';
}

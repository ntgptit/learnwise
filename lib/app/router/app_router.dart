// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
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
import '../../features/profile/view/profile_screen.dart';
import '../../features/profile/view/profile_personal_information_screen.dart';
import '../../features/profile/view/profile_user_settings_screen.dart';
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
  final String loginLocation = const LoginRoute().location;
  final String registerLocation = const RegisterRoute().location;
  final String dashboardLocation = const DashboardRoute().location;

  return GoRouter(
    initialLocation: loginLocation,
    refreshListenable: authSessionManager,
    redirect: (context, state) {
      final String location = state.uri.path;
      final bool isAuthRoute =
          location == loginLocation || location == registerLocation;
      if (!authSessionManager.isReady) {
        if (isAuthRoute) {
          return null;
        }
        return loginLocation;
      }
      if (!authSessionManager.isAuthenticated && !isAuthRoute) {
        return loginLocation;
      }
      if (authSessionManager.isAuthenticated && isAuthRoute) {
        return dashboardLocation;
      }
      return null;
    },
    routes: $appRoutes,
    errorBuilder: (context, state) {
      return const _NotFoundScreen();
    },
  );
}

@TypedGoRoute<RootRoute>(path: RouteNames.root)
class RootRoute extends GoRouteData with $RootRoute {
  const RootRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }
}

@TypedGoRoute<DashboardRoute>(path: RouteNames.dashboard)
class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }
}

@TypedGoRoute<FoldersRoute>(path: RouteNames.folders)
class FoldersRoute extends GoRouteData with $FoldersRoute {
  const FoldersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FolderScreen();
  }
}

@TypedGoRoute<ProfileRoute>(path: RouteNames.profile)
class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}

@TypedGoRoute<ProfilePersonalInfoRoute>(path: RouteNames.profilePersonalInfo)
class ProfilePersonalInfoRoute extends GoRouteData
    with $ProfilePersonalInfoRoute {
  const ProfilePersonalInfoRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePersonalInformationScreen();
  }
}

@TypedGoRoute<ProfileSettingsRoute>(path: RouteNames.profileSettings)
class ProfileSettingsRoute extends GoRouteData with $ProfileSettingsRoute {
  const ProfileSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileUserSettingsScreen();
  }
}

@TypedGoRoute<FlashcardsRoute>(path: RouteNames.flashcards)
class FlashcardsRoute extends GoRouteData with $FlashcardsRoute {
  const FlashcardsRoute({this.$extra});

  final FlashcardManagementArgs? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final FlashcardManagementArgs args =
        $extra ?? const FlashcardManagementArgs.fallback();
    return FlashcardManagementScreen(args: args);
  }
}

@TypedGoRoute<FlashcardFlipStudyRoute>(path: RouteNames.flashcardFlipStudy)
class FlashcardFlipStudyRoute extends GoRouteData
    with $FlashcardFlipStudyRoute {
  const FlashcardFlipStudyRoute({this.$extra});

  final FlashcardFlipStudyArgs? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final FlashcardFlipStudyArgs args =
        $extra ?? const FlashcardFlipStudyArgs.fallback();
    return FlashcardFlipStudyScreen(
      deckId: args.deckId,
      items: args.items,
      initialIndex: args.initialIndex,
      title: args.title,
    );
  }
}

@TypedGoRoute<FlashcardStudySessionRoute>(
  path: RouteNames.flashcardStudySession,
)
class FlashcardStudySessionRoute extends GoRouteData
    with $FlashcardStudySessionRoute {
  const FlashcardStudySessionRoute({this.$extra});

  final StudySessionArgs? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final StudySessionArgs args = $extra ?? const StudySessionArgs.fallback();
    return FlashcardStudySessionScreen(args: args);
  }
}

@TypedGoRoute<TtsRoute>(path: RouteNames.tts)
class TtsRoute extends GoRouteData with $TtsRoute {
  const TtsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TtsScreen();
  }
}

@TypedGoRoute<LoginRoute>(path: RouteNames.login)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginScreen();
  }
}

@TypedGoRoute<RegisterRoute>(path: RouteNames.register)
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RegisterScreen();
  }
}

@TypedGoRoute<LearningRoute>(path: RouteNames.learning)
class LearningRoute extends GoRouteData with $LearningRoute {
  const LearningRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const _StubScreen(title: _RouteText.learning);
  }
}

@TypedGoRoute<ProgressDetailRoute>(path: RouteNames.progressDetail)
class ProgressDetailRoute extends GoRouteData with $ProgressDetailRoute {
  const ProgressDetailRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const _StubScreen(title: _RouteText.progressDetail);
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

  static const String learning = 'Learning';
  static const String progressDetail = 'Progress Detail';
  static const String notImplementedSuffix = ' screen is not implemented yet.';
  static const String notFound = 'Route not found.';
}

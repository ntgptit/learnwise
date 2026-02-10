import 'route_names.dart';

class AppRedirects {
  const AppRedirects._();

  static String? authGuard({
    required bool isAuthenticated,
    required String currentLocation,
  }) {
    final bool isAuthScreen = currentLocation == RouteNames.login;

    if (!isAuthenticated && !isAuthScreen) {
      return RouteNames.login;
    }
    if (isAuthenticated && isAuthScreen) {
      return RouteNames.tts;
    }
    return null;
  }
}

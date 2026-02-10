class AppConstants {
  const AppConstants._();

  static const int retryCount = 2;
  static const int pageSize = 20;

  static const String appEnvDefineKey = 'APP_ENV';
  static const String defaultAppEnv = 'DEV';

  static const String defaultLanguageCode = 'en';
  static const String fallbackCountryCode = 'US';

  static const Duration apiConnectTimeout = Duration(seconds: 20);
  static const Duration apiReceiveTimeout = Duration(seconds: 20);
}

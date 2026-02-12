import 'app_constants.dart';

enum AppEnv {
  dev,
  stg,
  prod;

  static AppEnv fromDartDefine() {
    const String raw = String.fromEnvironment(
      AppConstants.appEnvDefineKey,
      defaultValue: AppConstants.defaultAppEnv,
    );
    return fromValue(raw);
  }

  static AppEnv fromValue(String value) {
    switch (value.trim().toUpperCase()) {
      case 'PROD':
      case 'PRODUCTION':
        return AppEnv.prod;
      case 'STG':
      case 'STAGE':
      case 'STAGING':
        return AppEnv.stg;
      case 'DEV':
      case 'DEVELOP':
      case 'DEVELOPMENT':
      default:
        return AppEnv.dev;
    }
  }
}

extension AppEnvX on AppEnv {
  bool get isDev => this == AppEnv.dev;
  bool get isStg => this == AppEnv.stg;
  bool get isProd => this == AppEnv.prod;
}

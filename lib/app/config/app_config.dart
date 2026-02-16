import '../../core/network/api_constants.dart';
import '../../core/utils/string_utils.dart';
import 'env.dart';
import 'app_constants.dart';

class AppConfig {
  const AppConfig({
    required this.env,
    required this.baseUrl,
    required this.apiVersion,
    required this.enableHttpLog,
    required this.enableRetry,
    required this.enableCrashReport,
    required this.enableMockApi,
  });

  final AppEnv env;
  final String baseUrl;
  final String apiVersion;
  final bool enableHttpLog;
  final bool enableRetry;
  final bool enableCrashReport;
  final bool enableMockApi;

  String get apiBasePath => '$baseUrl/$apiVersion';

  factory AppConfig.fromEnv([AppEnv? env]) {
    final AppEnv target = env ?? AppEnv.fromDartDefine();
    const String rawBaseUrlOverride = String.fromEnvironment(
      AppConstants.appApiBaseUrlDefineKey,
      defaultValue: '',
    );
    final String? baseUrlOverride = StringUtils.normalizeNullable(
      rawBaseUrlOverride,
    );
    switch (target) {
      case AppEnv.prod:
        return AppConfig(
          env: AppEnv.prod,
          baseUrl: baseUrlOverride ?? ApiConstants.prodBaseUrl,
          apiVersion: ApiConstants.apiVersion,
          enableHttpLog: false,
          enableRetry: true,
          enableCrashReport: true,
          enableMockApi: false,
        );
      case AppEnv.stg:
        return AppConfig(
          env: AppEnv.stg,
          baseUrl: baseUrlOverride ?? ApiConstants.stgBaseUrl,
          apiVersion: ApiConstants.apiVersion,
          enableHttpLog: true,
          enableRetry: true,
          enableCrashReport: false,
          enableMockApi: false,
        );
      case AppEnv.dev:
        return AppConfig(
          env: AppEnv.dev,
          baseUrl: baseUrlOverride ?? ApiConstants.devBaseUrl,
          apiVersion: ApiConstants.apiVersion,
          enableHttpLog: true,
          enableRetry: true,
          enableCrashReport: false,
          enableMockApi: true,
        );
    }
  }
}

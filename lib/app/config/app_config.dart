import '../../core/network/api_constants.dart';
import 'env.dart';

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
    switch (target) {
      case AppEnv.prod:
        return const AppConfig(
          env: AppEnv.prod,
          baseUrl: ApiConstants.prodBaseUrl,
          apiVersion: ApiConstants.apiVersion,
          enableHttpLog: false,
          enableRetry: true,
          enableCrashReport: true,
          enableMockApi: false,
        );
      case AppEnv.stg:
        return const AppConfig(
          env: AppEnv.stg,
          baseUrl: ApiConstants.stgBaseUrl,
          apiVersion: ApiConstants.apiVersion,
          enableHttpLog: true,
          enableRetry: true,
          enableCrashReport: false,
          enableMockApi: false,
        );
      case AppEnv.dev:
        return const AppConfig(
          env: AppEnv.dev,
          baseUrl: ApiConstants.devBaseUrl,
          apiVersion: ApiConstants.apiVersion,
          enableHttpLog: true,
          enableRetry: true,
          enableCrashReport: false,
          enableMockApi: true,
        );
    }
  }
}

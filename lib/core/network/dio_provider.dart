import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/config/app_config.dart';
import '../../app/config/app_const.dart';
import 'api_const.dart';
import 'auth_session.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/retry_policy.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) {
  return AppConfig.fromEnv();
}

@Riverpod(keepAlive: true)
RetryPolicy retryPolicy(Ref ref) {
  return RetryPolicy(
    maxRetryCount: AppConst.retryCount,
    baseDelay: ApiConst.retryBaseDelay,
    maxDelay: ApiConst.retryMaxDelay,
  );
}

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final AppConfig config = ref.read(appConfigProvider);
  _validateConfig(config);

  final BaseOptions options = BaseOptions(
    baseUrl: config.apiBasePath,
    connectTimeout: AppConst.apiConnectTimeout,
    receiveTimeout: AppConst.apiReceiveTimeout,
    sendTimeout: AppConst.apiConnectTimeout,
    responseType: ResponseType.json,
    receiveDataWhenStatusError: true,
    headers: <String, Object>{
      ApiConst.acceptHeader: ApiConst.jsonMimeType,
      ApiConst.contentTypeHeader: ApiConst.jsonMimeType,
    },
  );

  final Dio dio = Dio(options);
  final AuthSessionManager authSessionManager = ref.read(
    authSessionManagerProvider,
  );
  dio.interceptors.add(
    AuthInterceptor(
      authSessionManager: authSessionManager,
      executeRequest: dio.fetch<dynamic>,
    ),
  );

  if (config.enableRetry) {
    dio.interceptors.add(
      RetryInterceptor(dio: dio, retryPolicy: ref.read(retryPolicyProvider)),
    );
  }

  dio.interceptors.add(LoggingInterceptor(enabled: config.enableHttpLog));
  return dio;
}

void _validateConfig(AppConfig config) {
  final String basePath = config.apiBasePath.trim();
  if (basePath.isNotEmpty) {
    return;
  }
  throw StateError('AppConfig.apiBasePath must not be empty.');
}

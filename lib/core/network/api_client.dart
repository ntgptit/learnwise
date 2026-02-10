import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/api_error_mapper.dart';
import '../error/app_exception.dart';
import '../error/error_code.dart';
import 'api_const.dart';
import 'dio_provider.dart';

part 'api_client.g.dart';

typedef ApiDataDecoder<T> = T Function(dynamic data);

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final Dio dio = ref.read(dioProvider);
  final AppErrorMapper mapper = ref.read(appErrorMapperProvider);
  return ApiClient(dio: dio, errorMapper: mapper);
}

class ApiClient {
  ApiClient({required Dio dio, required AppErrorMapper errorMapper})
    : _dio = dio,
      _errorMapper = errorMapper;

  final Dio _dio;
  final AppErrorMapper _errorMapper;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
    bool allowRetry = true,
    bool allowRawBodyLogging = false,
  }) {
    _validatePath(path);
    final Options mergedOptions = _mergeOptions(
      options: options,
      requiresAuth: requiresAuth,
      allowRetry: allowRetry,
      allowRawBodyLogging: allowRawBodyLogging,
    );

    return _guard(() {
      return _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
    bool allowRetry = false,
    bool allowRawBodyLogging = false,
  }) {
    _validatePath(path);
    final Options mergedOptions = _mergeOptions(
      options: options,
      requiresAuth: requiresAuth,
      allowRetry: allowRetry,
      allowRawBodyLogging: allowRawBodyLogging,
    );

    return _guard(() {
      return _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
    bool allowRetry = true,
    bool allowRawBodyLogging = false,
  }) {
    _validatePath(path);
    final Options mergedOptions = _mergeOptions(
      options: options,
      requiresAuth: requiresAuth,
      allowRetry: allowRetry,
      allowRawBodyLogging: allowRawBodyLogging,
    );

    return _guard(() {
      return _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool requiresAuth = true,
    bool allowRetry = false,
    bool allowRawBodyLogging = false,
  }) {
    _validatePath(path);
    final Options mergedOptions = _mergeOptions(
      options: options,
      requiresAuth: requiresAuth,
      allowRetry: allowRetry,
      allowRawBodyLogging: allowRawBodyLogging,
    );

    return _guard(() {
      return _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
    bool allowRetry = true,
    bool allowRawBodyLogging = false,
  }) {
    _validatePath(path);
    final Options mergedOptions = _mergeOptions(
      options: options,
      requiresAuth: requiresAuth,
      allowRetry: allowRetry,
      allowRawBodyLogging: allowRawBodyLogging,
    );

    return _guard(() {
      return _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
      );
    });
  }

  Future<T> getData<T>(
    String path, {
    required ApiDataDecoder<T> decoder,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
    bool allowRetry = true,
    bool allowRawBodyLogging = false,
  }) async {
    final Response<dynamic> response = await get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      requiresAuth: requiresAuth,
      allowRetry: allowRetry,
      allowRawBodyLogging: allowRawBodyLogging,
    );
    return _decodeResponseData(response: response, decoder: decoder);
  }

  Future<List<T>> getListData<T>(
    String path, {
    required ApiDataDecoder<T> itemDecoder,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
    bool allowRetry = true,
    bool allowRawBodyLogging = false,
  }) async {
    final Response<dynamic> response = await get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      requiresAuth: requiresAuth,
      allowRetry: allowRetry,
      allowRawBodyLogging: allowRawBodyLogging,
    );

    final dynamic rawData = response.data;
    if (rawData is! List) {
      throw UnexpectedResponseAppException(statusCode: response.statusCode);
    }

    final List<T> decoded = <T>[];
    for (final dynamic item in rawData) {
      decoded.add(
        _decodeValue(
          value: item,
          decoder: itemDecoder,
          statusCode: response.statusCode,
        ),
      );
    }
    return decoded;
  }

  T _decodeResponseData<T>({
    required Response<dynamic> response,
    required ApiDataDecoder<T> decoder,
  }) {
    final dynamic data = response.data;
    if (data == null) {
      throw UnexpectedResponseAppException(statusCode: response.statusCode);
    }
    return _decodeValue(
      value: data,
      decoder: decoder,
      statusCode: response.statusCode,
    );
  }

  T _decodeValue<T>({
    required dynamic value,
    required ApiDataDecoder<T> decoder,
    required int? statusCode,
  }) {
    try {
      return decoder(value);
    } catch (error) {
      throw _errorMapper.toAppException(
        error,
        fallback: AppErrorCode.unexpectedResponse,
      );
    }
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error) {
      throw _errorMapper.toAppException(error);
    }
  }

  Options _mergeOptions({
    required Options? options,
    required bool requiresAuth,
    required bool allowRetry,
    required bool allowRawBodyLogging,
  }) {
    final Options sourceOptions = options ?? Options();
    final Map<String, dynamic> mergedExtra = <String, dynamic>{
      ...sourceOptions.extra ?? <String, dynamic>{},
    };

    if (!requiresAuth) {
      mergedExtra[ApiConst.skipAuthExtraKey] = true;
    }
    if (!allowRetry) {
      mergedExtra[ApiConst.skipRetryExtraKey] = true;
    }
    if (allowRawBodyLogging) {
      mergedExtra[ApiConst.rawBodyLoggingExtraKey] = true;
    }

    return sourceOptions.copyWith(extra: mergedExtra);
  }

  void _validatePath(String path) {
    if (path.trim().isNotEmpty) {
      return;
    }
    throw ArgumentError.value(path, 'path', 'Path must not be empty.');
  }
}

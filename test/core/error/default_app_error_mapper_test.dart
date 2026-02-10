import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/error/api_error_mapper.dart';
import 'package:learnwise/core/error/app_exception.dart';
import 'package:learnwise/core/error/error_code.dart';
import 'package:learnwise/core/network/api_const.dart';
import 'package:learnwise/features/tts/model/tts_exceptions.dart';

void main() {
  group('DefaultAppErrorMapper', () {
    const DefaultAppErrorMapper mapper = DefaultAppErrorMapper();

    test('maps TtsInitException to TtsAppException', () {
      final AppException exception = mapper.toAppException(
        const TtsInitException(),
      );

      expect(exception.code, AppErrorCode.ttsInitFailed);
      expect(exception, isA<TtsAppException>());
      expect(exception.messageKey, AppExceptionKey.ttsInitFailed);
    });

    test('maps Dio timeout to TimeoutAppException', () {
      final RequestOptions options = RequestOptions(path: '/v1/health');
      final DioException error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );

      final AppException exception = mapper.toAppException(error);
      expect(exception, isA<TimeoutAppException>());
      expect(exception.code, AppErrorCode.timeout);
    });

    test('maps Dio 404 to NotFoundAppException', () {
      final RequestOptions options = RequestOptions(path: '/v1/items/1');
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: options,
        statusCode: ApiConst.notFoundStatusCode,
      );
      final DioException error = DioException(
        requestOptions: options,
        response: response,
        type: DioExceptionType.badResponse,
      );

      final AppException exception = mapper.toAppException(error);
      expect(exception, isA<NotFoundAppException>());
      expect(exception.code, AppErrorCode.notFound);
    });

    test('maps fallback code for unknown error', () {
      final AppException exception = mapper.toAppException(
        StateError('x'),
        fallback: AppErrorCode.networkUnavailable,
      );

      expect(exception, isA<NetworkAppException>());
      expect(exception.code, AppErrorCode.networkUnavailable);
    });
  });
}

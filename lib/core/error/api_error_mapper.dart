// quality-guard: allow-long-function - phase3 legacy backlog tracked for incremental extraction.
// quality-guard: allow-large-class - phase2 legacy backlog tracked for class decomposition.
// quality-guard: allow-large-file - phase2 legacy backlog tracked for file modularization.
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/tts/model/tts_exceptions.dart';
import '../network/api_constants.dart';
import '../utils/string_utils.dart';
import 'app_exception.dart';
import 'app_error_bus.dart';
import 'error_code.dart';

part 'api_error_mapper.g.dart';

@Riverpod(keepAlive: true)
AppErrorMapper appErrorMapper(Ref ref) {
  return const DefaultAppErrorMapper();
}

@Riverpod(keepAlive: true)
AppErrorAdvisor appErrorAdvisor(Ref ref) {
  final AppErrorMapper mapper = ref.read(appErrorMapperProvider);
  return AppErrorAdvisor(ref: ref, mapper: mapper);
}

abstract class AppErrorMapper {
  AppException toAppException(
    Object error, {
    AppErrorCode fallback = AppErrorCode.unknown,
  });
}

class DefaultAppErrorMapper implements AppErrorMapper {
  const DefaultAppErrorMapper();

  @override
  AppException toAppException(
    Object error, {
    AppErrorCode fallback = AppErrorCode.unknown,
  }) {
    if (error is AppException) {
      return error;
    }

    if (error is TtsInitException) {
      return TtsAppException(
        code: AppErrorCode.ttsInitFailed,
        message: AppExceptionMessage.ttsInitFailed,
        messageKey: AppExceptionKey.ttsInitFailed,
        cause: error.cause,
      );
    }

    if (error is TtsLoadVoicesException) {
      return TtsAppException(
        code: AppErrorCode.ttsLoadVoicesFailed,
        message: AppExceptionMessage.ttsLoadVoicesFailed,
        messageKey: AppExceptionKey.ttsLoadVoicesFailed,
        cause: error.cause,
      );
    }

    if (error is TtsSpeakException) {
      return TtsAppException(
        code: AppErrorCode.ttsReadFailed,
        message: AppExceptionMessage.ttsReadFailed,
        messageKey: AppExceptionKey.ttsReadFailed,
        cause: error.cause,
      );
    }

    if (error is TtsStopException) {
      return TtsAppException(
        code: AppErrorCode.ttsStopFailed,
        message: AppExceptionMessage.ttsStopFailed,
        messageKey: AppExceptionKey.ttsStopFailed,
        cause: error.cause,
      );
    }

    if (error is DioException) {
      return _mapDioException(error, fallback: fallback);
    }

    return _mapFallback(error: error, fallback: fallback);
  }

  AppException _mapDioException(
    DioException error, {
    required AppErrorCode fallback,
  }) {
    if (_isTimeout(error.type)) {
      return TimeoutAppException(cause: error);
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkAppException(cause: error);
    }

    final int? statusCode = error.response?.statusCode;
    if (statusCode == null) {
      return _mapFallback(error: error, fallback: fallback);
    }

    if (statusCode == ApiConstants.badRequestStatusCode) {
      return BadRequestAppException(statusCode: statusCode, cause: error);
    }

    if (statusCode == ApiConstants.unauthorizedStatusCode) {
      return UnauthorizedAppException(statusCode: statusCode, cause: error);
    }

    if (statusCode == ApiConstants.forbiddenStatusCode) {
      return ForbiddenAppException(statusCode: statusCode, cause: error);
    }

    if (statusCode == ApiConstants.notFoundStatusCode) {
      return NotFoundAppException(statusCode: statusCode, cause: error);
    }

    if (statusCode == ApiConstants.conflictStatusCode) {
      return ConflictAppException(statusCode: statusCode, cause: error);
    }

    if (statusCode == ApiConstants.unprocessableEntityStatusCode) {
      return UnprocessableEntityAppException(
        statusCode: statusCode,
        cause: error,
      );
    }

    if (statusCode == ApiConstants.tooManyRequestsStatusCode) {
      return TooManyRequestsAppException(statusCode: statusCode, cause: error);
    }

    if (_isServerError(statusCode)) {
      return ServerAppException(statusCode: statusCode, cause: error);
    }

    return UnexpectedResponseAppException(statusCode: statusCode, cause: error);
  }

  AppException _mapFallback({
    required Object error,
    required AppErrorCode fallback,
  }) {
    if (fallback == AppErrorCode.badRequest) {
      return BadRequestAppException(cause: error);
    }

    if (fallback == AppErrorCode.unauthorized) {
      return UnauthorizedAppException(cause: error);
    }

    if (fallback == AppErrorCode.forbidden) {
      return ForbiddenAppException(cause: error);
    }

    if (fallback == AppErrorCode.notFound) {
      return NotFoundAppException(cause: error);
    }

    if (fallback == AppErrorCode.conflict) {
      return ConflictAppException(cause: error);
    }

    if (fallback == AppErrorCode.unprocessableEntity) {
      return UnprocessableEntityAppException(cause: error);
    }

    if (fallback == AppErrorCode.tooManyRequests) {
      return TooManyRequestsAppException(cause: error);
    }

    if (fallback == AppErrorCode.serverError) {
      return ServerAppException(cause: error);
    }

    if (fallback == AppErrorCode.networkUnavailable) {
      return NetworkAppException(cause: error);
    }

    if (fallback == AppErrorCode.timeout) {
      return TimeoutAppException(cause: error);
    }

    if (fallback == AppErrorCode.unexpectedResponse) {
      return UnexpectedResponseAppException(cause: error);
    }

    if (fallback == AppErrorCode.dashboardLoadFailed) {
      return UnknownAppException(
        code: AppErrorCode.dashboardLoadFailed,
        message: AppExceptionMessage.dashboardLoadFailed,
        messageKey: AppExceptionKey.dashboardLoadFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.folderLoadFailed) {
      return UnknownAppException(
        code: AppErrorCode.folderLoadFailed,
        message: AppExceptionMessage.folderLoadFailed,
        messageKey: AppExceptionKey.folderLoadFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.folderCreateFailed) {
      return UnknownAppException(
        code: AppErrorCode.folderCreateFailed,
        message: AppExceptionMessage.folderCreateFailed,
        messageKey: AppExceptionKey.folderCreateFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.folderUpdateFailed) {
      return UnknownAppException(
        code: AppErrorCode.folderUpdateFailed,
        message: AppExceptionMessage.folderUpdateFailed,
        messageKey: AppExceptionKey.folderUpdateFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.folderDeleteFailed) {
      return UnknownAppException(
        code: AppErrorCode.folderDeleteFailed,
        message: AppExceptionMessage.folderDeleteFailed,
        messageKey: AppExceptionKey.folderDeleteFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.folderRestoreFailed) {
      return UnknownAppException(
        code: AppErrorCode.folderRestoreFailed,
        message: AppExceptionMessage.folderRestoreFailed,
        messageKey: AppExceptionKey.folderRestoreFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.flashcardLoadFailed) {
      return UnknownAppException(
        code: AppErrorCode.flashcardLoadFailed,
        message: AppExceptionMessage.flashcardLoadFailed,
        messageKey: AppExceptionKey.flashcardLoadFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.flashcardCreateFailed) {
      return UnknownAppException(
        code: AppErrorCode.flashcardCreateFailed,
        message: AppExceptionMessage.flashcardCreateFailed,
        messageKey: AppExceptionKey.flashcardCreateFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.flashcardUpdateFailed) {
      return UnknownAppException(
        code: AppErrorCode.flashcardUpdateFailed,
        message: AppExceptionMessage.flashcardUpdateFailed,
        messageKey: AppExceptionKey.flashcardUpdateFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.flashcardDeleteFailed) {
      return UnknownAppException(
        code: AppErrorCode.flashcardDeleteFailed,
        message: AppExceptionMessage.flashcardDeleteFailed,
        messageKey: AppExceptionKey.flashcardDeleteFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.ttsInitFailed) {
      return TtsAppException(
        code: AppErrorCode.ttsInitFailed,
        message: AppExceptionMessage.ttsInitFailed,
        messageKey: AppExceptionKey.ttsInitFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.ttsLoadVoicesFailed) {
      return TtsAppException(
        code: AppErrorCode.ttsLoadVoicesFailed,
        message: AppExceptionMessage.ttsLoadVoicesFailed,
        messageKey: AppExceptionKey.ttsLoadVoicesFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.ttsReadFailed) {
      return TtsAppException(
        code: AppErrorCode.ttsReadFailed,
        message: AppExceptionMessage.ttsReadFailed,
        messageKey: AppExceptionKey.ttsReadFailed,
        cause: error,
      );
    }

    if (fallback == AppErrorCode.ttsStopFailed) {
      return TtsAppException(
        code: AppErrorCode.ttsStopFailed,
        message: AppExceptionMessage.ttsStopFailed,
        messageKey: AppExceptionKey.ttsStopFailed,
        cause: error,
      );
    }

    return UnknownAppException(cause: error);
  }

  bool _isServerError(int statusCode) {
    return statusCode >= ApiConstants.serverErrorLowerBound &&
        statusCode <= ApiConstants.serverErrorUpperBound;
  }

  bool _isTimeout(DioExceptionType type) {
    if (type == DioExceptionType.connectionTimeout) {
      return true;
    }
    if (type == DioExceptionType.sendTimeout) {
      return true;
    }
    if (type == DioExceptionType.receiveTimeout) {
      return true;
    }
    return false;
  }
}

class AppErrorAdvisor {
  AppErrorAdvisor({required Ref ref, required AppErrorMapper mapper})
    : _ref = ref,
      _mapper = mapper;

  final Ref _ref;
  final AppErrorMapper _mapper;

  void handle(Object error, {AppErrorCode fallback = AppErrorCode.unknown}) {
    final AppException exception = toAppException(error, fallback: fallback);
    final String? backendMessage = _resolveBackendMessage(
      error: error,
      exception: exception,
    );
    _ref
        .read(appErrorBusProvider.notifier)
        .report(exception.code, message: backendMessage);
  }

  AppException toAppException(
    Object error, {
    AppErrorCode fallback = AppErrorCode.unknown,
  }) {
    return _mapper.toAppException(error, fallback: fallback);
  }

  String? extractBackendMessage(Object? error) {
    return _extractBackendMessage(error);
  }

  String? _resolveBackendMessage({
    required Object error,
    required AppException exception,
  }) {
    final String? errorMessage = _extractBackendMessage(error);
    if (errorMessage != null) {
      return errorMessage;
    }
    return _extractBackendMessage(exception.cause);
  }

  String? _extractBackendMessage(Object? error) {
    if (error is DioException) {
      return _extractBackendMessageFromPayload(error.response?.data);
    }

    if (error is AppException) {
      return _extractBackendMessage(error.cause);
    }

    return null;
  }

  String? _extractBackendMessageFromPayload(dynamic payload) {
    if (payload is! Map) {
      return null;
    }
    final dynamic rawMessage = payload['message'];
    if (rawMessage is! String) {
      return null;
    }
    return StringUtils.normalizeNullable(rawMessage);
  }
}

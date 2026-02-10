import 'error_code.dart';

class AppExceptionMessage {
  const AppExceptionMessage._();

  static const String unknown = 'Unexpected application error.';
  static const String badRequest = 'Invalid request payload.';
  static const String unauthorized = 'Authentication required.';
  static const String forbidden = 'Permission denied.';
  static const String notFound = 'Requested resource not found.';
  static const String conflict = 'Resource conflict detected.';
  static const String unprocessableEntity = 'Request data is not processable.';
  static const String tooManyRequests = 'Rate limit exceeded.';
  static const String serverError = 'Server failed to process the request.';
  static const String networkUnavailable = 'Network connection is unavailable.';
  static const String timeout = 'Request timed out.';
  static const String unexpectedResponse = 'Server response format is invalid.';
  static const String dashboardLoadFailed = 'Failed to load dashboard data.';
  static const String folderLoadFailed = 'Failed to load folders.';
  static const String folderCreateFailed = 'Failed to create folder.';
  static const String folderUpdateFailed = 'Failed to update folder.';
  static const String folderDeleteFailed = 'Failed to delete folder.';
  static const String folderRestoreFailed = 'Failed to restore folder.';
  static const String ttsInitFailed = 'Failed to initialize text-to-speech.';
  static const String ttsLoadVoicesFailed =
      'Failed to load text-to-speech voices.';
  static const String ttsReadFailed = 'Failed to read text via text-to-speech.';
  static const String ttsStopFailed = 'Failed to stop text-to-speech playback.';
}

class AppExceptionKey {
  const AppExceptionKey._();

  static const String unknown = 'error.unknown';
  static const String badRequest = 'error.badRequest';
  static const String unauthorized = 'error.unauthorized';
  static const String forbidden = 'error.forbidden';
  static const String notFound = 'error.notFound';
  static const String conflict = 'error.conflict';
  static const String unprocessableEntity = 'error.unprocessableEntity';
  static const String tooManyRequests = 'error.tooManyRequests';
  static const String serverError = 'error.serverError';
  static const String networkUnavailable = 'error.networkUnavailable';
  static const String timeout = 'error.timeout';
  static const String unexpectedResponse = 'error.unexpectedResponse';
  static const String dashboardLoadFailed = 'error.dashboardLoadFailed';
  static const String folderLoadFailed = 'error.folderLoadFailed';
  static const String folderCreateFailed = 'error.folderCreateFailed';
  static const String folderUpdateFailed = 'error.folderUpdateFailed';
  static const String folderDeleteFailed = 'error.folderDeleteFailed';
  static const String folderRestoreFailed = 'error.folderRestoreFailed';
  static const String ttsInitFailed = 'error.ttsInitFailed';
  static const String ttsLoadVoicesFailed = 'error.ttsLoadVoicesFailed';
  static const String ttsReadFailed = 'error.ttsReadFailed';
  static const String ttsStopFailed = 'error.ttsStopFailed';
}

sealed class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    required this.messageKey,
    this.statusCode,
    this.cause,
  });

  final AppErrorCode code;
  final String message;
  final String messageKey;
  final int? statusCode;
  final Object? cause;
}

class UnknownAppException extends AppException {
  const UnknownAppException({
    super.code = AppErrorCode.unknown,
    super.message = AppExceptionMessage.unknown,
    super.messageKey = AppExceptionKey.unknown,
    super.cause,
  });
}

class BadRequestAppException extends AppException {
  const BadRequestAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.badRequest,
        message: AppExceptionMessage.badRequest,
        messageKey: AppExceptionKey.badRequest,
      );
}

class UnauthorizedAppException extends AppException {
  const UnauthorizedAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.unauthorized,
        message: AppExceptionMessage.unauthorized,
        messageKey: AppExceptionKey.unauthorized,
      );
}

class ForbiddenAppException extends AppException {
  const ForbiddenAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.forbidden,
        message: AppExceptionMessage.forbidden,
        messageKey: AppExceptionKey.forbidden,
      );
}

class NotFoundAppException extends AppException {
  const NotFoundAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.notFound,
        message: AppExceptionMessage.notFound,
        messageKey: AppExceptionKey.notFound,
      );
}

class ConflictAppException extends AppException {
  const ConflictAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.conflict,
        message: AppExceptionMessage.conflict,
        messageKey: AppExceptionKey.conflict,
      );
}

class UnprocessableEntityAppException extends AppException {
  const UnprocessableEntityAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.unprocessableEntity,
        message: AppExceptionMessage.unprocessableEntity,
        messageKey: AppExceptionKey.unprocessableEntity,
      );
}

class TooManyRequestsAppException extends AppException {
  const TooManyRequestsAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.tooManyRequests,
        message: AppExceptionMessage.tooManyRequests,
        messageKey: AppExceptionKey.tooManyRequests,
      );
}

class ServerAppException extends AppException {
  const ServerAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.serverError,
        message: AppExceptionMessage.serverError,
        messageKey: AppExceptionKey.serverError,
      );
}

class NetworkAppException extends AppException {
  const NetworkAppException({super.cause})
    : super(
        code: AppErrorCode.networkUnavailable,
        message: AppExceptionMessage.networkUnavailable,
        messageKey: AppExceptionKey.networkUnavailable,
      );
}

class TimeoutAppException extends AppException {
  const TimeoutAppException({super.cause})
    : super(
        code: AppErrorCode.timeout,
        message: AppExceptionMessage.timeout,
        messageKey: AppExceptionKey.timeout,
      );
}

class UnexpectedResponseAppException extends AppException {
  const UnexpectedResponseAppException({super.statusCode, super.cause})
    : super(
        code: AppErrorCode.unexpectedResponse,
        message: AppExceptionMessage.unexpectedResponse,
        messageKey: AppExceptionKey.unexpectedResponse,
      );
}

class TtsAppException extends AppException {
  const TtsAppException({
    required super.code,
    required super.message,
    required super.messageKey,
    super.cause,
  });
}

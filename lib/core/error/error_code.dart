enum AppErrorCode {
  unknown,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  unprocessableEntity,
  tooManyRequests,
  serverError,
  networkUnavailable,
  timeout,
  unexpectedResponse,
  dashboardLoadFailed,
  folderLoadFailed,
  folderCreateFailed,
  folderUpdateFailed,
  folderDeleteFailed,
  folderRestoreFailed,
  flashcardLoadFailed,
  flashcardCreateFailed,
  flashcardUpdateFailed,
  flashcardDeleteFailed,
  ttsInitFailed,
  ttsLoadVoicesFailed,
  ttsReadFailed,
  ttsStopFailed,
}

extension AppErrorCodeX on AppErrorCode {
  bool get isAuthError {
    if (this == AppErrorCode.unauthorized) {
      return true;
    }
    if (this == AppErrorCode.forbidden) {
      return true;
    }
    return false;
  }

  bool get isRetryable {
    if (this == AppErrorCode.networkUnavailable) {
      return true;
    }
    if (this == AppErrorCode.timeout) {
      return true;
    }
    if (this == AppErrorCode.serverError) {
      return true;
    }
    if (this == AppErrorCode.tooManyRequests) {
      return true;
    }
    return false;
  }
}

class ApiConst {
  const ApiConst._();

  static const String apiVersion = 'v1';

  static const String devBaseUrl = 'http://192.168.35.154:8080';
  static const String stgBaseUrl = 'https://stg-api.learnwise.com';
  static const String prodBaseUrl = 'https://api.learnwise.com';

  static const String jsonMimeType = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String acceptHeader = 'Accept';
  static const String contentTypeHeader = 'Content-Type';
  static const String bearerTokenPrefix = 'Bearer ';
  static const String requestIdHeader = 'X-Request-Id';
  static const String requestDurationHeader = 'X-Request-Duration-Ms';

  static const String skipAuthExtraKey = 'skipAuth';
  static const String skipRetryExtraKey = 'skipRetry';
  static const String authRetriedExtraKey = 'authRetried';
  static const String rawBodyLoggingExtraKey = 'allowRawBodyLogging';

  static const int badRequestStatusCode = 400;
  static const int unauthorizedStatusCode = 401;
  static const int forbiddenStatusCode = 403;
  static const int notFoundStatusCode = 404;
  static const int conflictStatusCode = 409;
  static const int unprocessableEntityStatusCode = 422;
  static const int tooManyRequestsStatusCode = 429;
  static const int serverErrorLowerBound = 500;
  static const int serverErrorUpperBound = 599;

  static const String retryAttemptKey = 'retryAttempt';
  static const Duration retryBaseDelay = Duration(milliseconds: 450);
  static const Duration retryMaxDelay = Duration(seconds: 5);

  static const String methodGet = 'GET';
  static const String methodHead = 'HEAD';
  static const String methodOptions = 'OPTIONS';
}

package com.learn.wire.exception;

import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import org.apache.commons.lang3.StringUtils;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ErrorMessageConst;
import com.learn.wire.dto.ApiErrorResponse;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestControllerAdvice
@Slf4j
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private final MessageSource messageSource;

    @ExceptionHandler(ApiException.class)
    ResponseEntity<ApiErrorResponse> handleApiException(
            ApiException exception,
            HttpServletRequest request) {
        final var message = resolveMessage(exception.getMessageKey(), exception.getMessageArgs());
        logByStatus(exception.getStatus(), exception, request.getRequestURI());
        return ResponseEntity.status(exception.getStatus()).body(
                ApiErrorResponse.of(
                        exception.getCode(),
                        message,
                        exception.getCode(),
                        request.getRequestURI()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiErrorResponse> handleValidationError(
            MethodArgumentNotValidException exception,
            HttpServletRequest request) {
        final FieldError fieldError = exception.getBindingResult().getFieldError();
        final String message = resolveFieldErrorMessage(fieldError);
        final String detail = resolveFieldDetail(fieldError);
        log.warn("Validation failure at path {} with detail {}", request.getRequestURI(), detail);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                ApiErrorResponse.of(
                        ApiConst.ERROR_CODE_BAD_REQUEST,
                        message,
                        detail,
                        request.getRequestURI()));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    ResponseEntity<ApiErrorResponse> handleUnreadablePayload(
            HttpMessageNotReadableException exception,
            HttpServletRequest request) {
        final String message = resolveMessage(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        log.warn("Unreadable payload at path {}", request.getRequestURI(), exception);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                ApiErrorResponse.of(
                        ApiConst.ERROR_CODE_BAD_REQUEST,
                        message,
                        ApiConst.ERROR_DETAIL_INVALID_PAYLOAD,
                        request.getRequestURI()));
    }

    @ExceptionHandler(RuntimeException.class)
    ResponseEntity<ApiErrorResponse> handleUnexpected(
            RuntimeException exception,
            HttpServletRequest request) {
        final String message = resolveMessage(ErrorMessageConst.COMMON_ERROR_RUNTIME);
        log.error("Unhandled runtime exception at path {}", request.getRequestURI(), exception);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(
                ApiErrorResponse.of(
                        ApiConst.ERROR_CODE_INTERNAL_ERROR,
                        message,
                        ApiConst.ERROR_DETAIL_INTERNAL,
                        request.getRequestURI()));
    }

    private String resolveFieldErrorMessage(FieldError fieldError) {
        if (fieldError == null) {
            return resolveMessage(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }

        final String message = fieldError.getDefaultMessage();
        if (StringUtils.isBlank(message)) {
            return resolveMessage(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }

        if (!message.startsWith("{") || !message.endsWith("}")) {
            return message;
        }

        final var key = message.substring(1, message.length() - 1);
        return resolveMessage(key);
    }

    private String resolveFieldDetail(FieldError fieldError) {
        if (fieldError == null) {
            return ApiConst.ERROR_DETAIL_VALIDATION;
        }

        final String fieldName = fieldError.getField();
        if (StringUtils.isBlank(fieldName)) {
            return ApiConst.ERROR_DETAIL_VALIDATION;
        }
        return ApiConst.ERROR_DETAIL_FIELD_PREFIX + fieldName;
    }

    private void logByStatus(HttpStatus status, ApiException exception, String path) {
        if (status.is4xxClientError()) {
            log.warn(
                    "ApiException at path {} with status {} and code {}",
                    path,
                    status.value(),
                    exception.getCode());
            return;
        }
        log.error(
                "ApiException at path {} with status {} and code {}",
                path,
                status.value(),
                exception.getCode(),
                exception);
    }

    private String resolveMessage(String key, Object... args) {
        return this.messageSource.getMessage(
                key,
                args,
                key,
                LocaleContextHolder.getLocale());
    }
}


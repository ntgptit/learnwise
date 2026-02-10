package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;

public class ValidationException extends ApiException {

    private static final long serialVersionUID = 1L;

    protected ValidationException(String code, String messageKey, Object... messageArgs) {
        super(code, HttpStatus.BAD_REQUEST, messageKey, messageArgs);
    }

    public ValidationException(String messageKey, Object... messageArgs) {
        this(ApiConst.ERROR_CODE_VALIDATION, messageKey, messageArgs);
    }
}

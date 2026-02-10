package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;

public class BadRequestException extends ApiException {

    private static final long serialVersionUID = 1L;

    public BadRequestException(String messageKey, Object... messageArgs) {
        super(
                ApiConst.ERROR_CODE_BAD_REQUEST,
                HttpStatus.BAD_REQUEST,
                messageKey,
                messageArgs);
    }
}

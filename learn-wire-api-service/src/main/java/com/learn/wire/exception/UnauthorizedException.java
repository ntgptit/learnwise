package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;

public class UnauthorizedException extends ApiException {

    private static final long serialVersionUID = 1L;

    public UnauthorizedException(String messageKey, Object... messageArgs) {
        super(
                ApiConst.ERROR_CODE_UNAUTHORIZED,
                HttpStatus.UNAUTHORIZED,
                messageKey,
                messageArgs);
    }
}

package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;

public class IntegrationException extends ApiException {

    private static final long serialVersionUID = 1L;

    protected IntegrationException(String code, String messageKey, Object... messageArgs) {
        super(code, HttpStatus.BAD_GATEWAY, messageKey, messageArgs);
    }

    public IntegrationException(String messageKey, Object... messageArgs) {
        this(ApiConst.ERROR_CODE_INTEGRATION, messageKey, messageArgs);
    }
}

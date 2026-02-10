package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;

public class BusinessException extends ApiException {

    private static final long serialVersionUID = 1L;

    protected BusinessException(String code, String messageKey, Object... messageArgs) {
        super(code, HttpStatus.CONFLICT, messageKey, messageArgs);
    }

    public BusinessException(String messageKey, Object... messageArgs) {
        this(ApiConst.ERROR_CODE_BUSINESS, messageKey, messageArgs);
    }
}

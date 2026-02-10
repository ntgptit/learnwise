package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;

public class ResourceNotFoundException extends ApiException {

    private static final long serialVersionUID = 1L;

    protected ResourceNotFoundException(String code, String messageKey, Object... messageArgs) {
        super(code, HttpStatus.NOT_FOUND, messageKey, messageArgs);
    }

    public ResourceNotFoundException(String messageKey, Object... messageArgs) {
        this(ApiConst.ERROR_CODE_RESOURCE_NOT_FOUND, messageKey, messageArgs);
    }
}

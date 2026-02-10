package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import lombok.Getter;

@Getter
public abstract class ApiException extends RuntimeException {

    private static final long serialVersionUID = 1L;
    private final String code;
    private final HttpStatus status;
    private final String messageKey;
    private final transient Object[] messageArgs;

    protected ApiException(
            String code,
            HttpStatus status,
            String messageKey,
            Object... messageArgs) {
        super(messageKey);
        this.code = code;
        this.status = status;
        this.messageKey = messageKey;
        this.messageArgs = messageArgs == null ? new Object[0] : messageArgs.clone();
    }
}

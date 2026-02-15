package com.learn.wire.exception;

import com.learn.wire.constant.StudyConst;

public class StudyEventNotSupportedException extends BusinessException {

    private static final long serialVersionUID = 1L;

    public StudyEventNotSupportedException(String mode, String eventType) {
        super(StudyConst.EVENT_NOT_SUPPORTED_KEY, mode, eventType);
    }
}

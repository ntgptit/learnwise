package com.learn.wire.exception;

import com.learn.wire.constant.StudyConst;

public class StudySessionNotFoundException extends ResourceNotFoundException {

    private static final long serialVersionUID = 1L;

    public StudySessionNotFoundException(Long sessionId) {
        super(StudyConst.SESSION_NOT_FOUND_KEY, sessionId);
    }
}

package com.learn.wire.exception;

import com.learn.wire.constant.StudyConst;

public class MatchSessionStateNotFoundException extends ResourceNotFoundException {

    private static final long serialVersionUID = 1L;

    public MatchSessionStateNotFoundException(Long sessionId) {
        super(StudyConst.MATCH_STATE_NOT_FOUND_KEY, sessionId);
    }
}

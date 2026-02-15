package com.learn.wire.service;

import com.learn.wire.dto.study.request.StudySessionEventRequest;
import com.learn.wire.dto.study.request.StudySessionStartRequest;
import com.learn.wire.dto.study.response.StudySessionResponse;

public interface StudySessionService {

    StudySessionResponse startSession(Long deckId, StudySessionStartRequest request);

    StudySessionResponse getSession(Long sessionId);

    StudySessionResponse submitEvent(Long sessionId, StudySessionEventRequest request);

    StudySessionResponse completeSession(Long sessionId);
}

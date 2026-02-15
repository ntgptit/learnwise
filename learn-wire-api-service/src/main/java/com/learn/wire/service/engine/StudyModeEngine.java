package com.learn.wire.service.engine;

import java.util.List;

import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.dto.study.query.StudySessionEventCommand;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.StudySessionEntity;

public interface StudyModeEngine {

    StudyMode mode();

    void initializeSession(StudySessionEntity session, List<FlashcardEntity> flashcards);

    StudySessionResponse buildResponse(StudySessionEntity session);

    StudySessionResponse handleEvent(StudySessionEntity session, StudySessionEventCommand command);
}

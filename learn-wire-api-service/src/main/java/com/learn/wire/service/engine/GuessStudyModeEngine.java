package com.learn.wire.service.engine;

import org.springframework.stereotype.Component;

import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.repository.StudyAttemptRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionRepository;

@Component
public class GuessStudyModeEngine extends AbstractLinearStudyModeEngine {

    public GuessStudyModeEngine(
            StudySessionRepository studySessionRepository,
            StudySessionModeStateRepository studySessionModeStateRepository,
            StudySessionItemRepository studySessionItemRepository,
            StudyAttemptRepository studyAttemptRepository) {
        super(
                StudyMode.GUESS,
                studySessionRepository,
                studySessionModeStateRepository,
                studySessionItemRepository,
                studyAttemptRepository);
    }
}

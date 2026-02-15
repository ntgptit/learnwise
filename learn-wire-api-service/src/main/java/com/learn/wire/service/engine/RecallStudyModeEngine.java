package com.learn.wire.service.engine;

import org.springframework.stereotype.Component;

import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.repository.StudyAttemptRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionRepository;

@Component
public class RecallStudyModeEngine extends AbstractLinearStudyModeEngine {

    public RecallStudyModeEngine(
            StudySessionRepository studySessionRepository,
            StudySessionModeStateRepository studySessionModeStateRepository,
            StudySessionItemRepository studySessionItemRepository,
            StudyAttemptRepository studyAttemptRepository) {
        super(
                StudyMode.RECALL,
                studySessionRepository,
                studySessionModeStateRepository,
                studySessionItemRepository,
                studyAttemptRepository);
    }
}

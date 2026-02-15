package com.learn.wire.service.impl;

import java.time.Instant;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.dto.study.query.StudySessionEventCommand;
import com.learn.wire.dto.study.query.StudySessionStartCommand;
import com.learn.wire.dto.study.request.StudySessionEventRequest;
import com.learn.wire.dto.study.request.StudySessionStartRequest;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.entity.DeckEntity;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.StudySessionEntity;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.DeckNotFoundException;
import com.learn.wire.exception.StudySessionNotFoundException;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.StudySessionRepository;
import com.learn.wire.service.StudySessionService;
import com.learn.wire.service.engine.StudyModeEngine;
import com.learn.wire.service.factory.StudyEngineFactory;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class StudySessionServiceImpl implements StudySessionService {

    private final DeckRepository deckRepository;
    private final FlashcardRepository flashcardRepository;
    private final StudySessionRepository studySessionRepository;
    private final StudyEngineFactory studyEngineFactory;

    @Override
    public StudySessionResponse startSession(Long deckId, StudySessionStartRequest request) {
        final StudySessionStartCommand command = StudySessionStartCommand.fromRequest(deckId, request);
        log.debug(
                "Start study session with deckId={}, mode={}, seed={}",
                command.deckId(),
                command.mode().value(),
                command.seed());
        getActiveDeckEntity(command.deckId());
        final List<FlashcardEntity> flashcards = this.flashcardRepository.findByDeckIdAndDeletedAtIsNull(command.deckId());
        if (!flashcards.isEmpty()) {
            final StudySessionEntity session = createSession(command);
            final StudySessionEntity createdSession = this.studySessionRepository.save(session);
            final StudyModeEngine engine = this.studyEngineFactory.getEngine(command.mode());
            engine.initializeSession(createdSession, flashcards);
            final StudySessionEntity refreshedSession = getActiveSessionEntity(createdSession.getId());
            return engine.buildResponse(refreshedSession);
        }
        throw new BusinessException(StudyConst.DECK_HAS_NO_FLASHCARDS_KEY, command.deckId());
    }

    @Override
    @Transactional(readOnly = true)
    public StudySessionResponse getSession(Long sessionId) {
        final StudySessionEntity session = getActiveSessionEntity(sessionId);
        final StudyModeEngine engine = resolveEngine(session);
        return engine.buildResponse(session);
    }

    @Override
    public StudySessionResponse submitEvent(Long sessionId, StudySessionEventRequest request) {
        final StudySessionEventCommand command = StudySessionEventCommand.fromRequest(request);
        final StudySessionEntity session = getActiveSessionEntity(sessionId);
        final StudyModeEngine engine = resolveEngine(session);
        return engine.handleEvent(session, command);
    }

    @Override
    public StudySessionResponse completeSession(Long sessionId) {
        final StudySessionEntity session = getActiveSessionEntity(sessionId);
        if (!StudyConst.SESSION_STATUS_ACTIVE.equalsIgnoreCase(session.getStatus())) {
            return resolveEngine(session).buildResponse(session);
        }
        session.setStatus(StudyConst.SESSION_STATUS_COMPLETED);
        session.setCompletedAt(Instant.now());
        session.setUpdatedBy(StudyConst.DEFAULT_ACTOR);
        final StudySessionEntity completedSession = this.studySessionRepository.save(session);
        return resolveEngine(completedSession).buildResponse(completedSession);
    }

    private StudyModeEngine resolveEngine(StudySessionEntity session) {
        final StudyMode mode = StudyMode.fromValue(session.getMode());
        return this.studyEngineFactory.getEngine(mode);
    }

    private StudySessionEntity createSession(StudySessionStartCommand command) {
        final StudySessionEntity session = new StudySessionEntity();
        session.setDeckId(command.deckId());
        session.setMode(command.mode().value());
        session.setStatus(StudyConst.SESSION_STATUS_ACTIVE);
        session.setSeed(command.seed());
        session.setCurrentIndex(StudyConst.DEFAULT_INDEX);
        session.setTotalUnits(StudyConst.DEFAULT_INDEX);
        session.setCorrectCount(StudyConst.ZERO_SCORE);
        session.setWrongCount(StudyConst.ZERO_SCORE);
        session.setStartedAt(Instant.now());
        session.setCreatedBy(StudyConst.DEFAULT_ACTOR);
        session.setUpdatedBy(StudyConst.DEFAULT_ACTOR);
        return session;
    }

    private DeckEntity getActiveDeckEntity(Long deckId) {
        return this.deckRepository
                .findByIdAndDeletedAtIsNull(deckId)
                .orElseThrow(() -> new DeckNotFoundException(deckId));
    }

    private StudySessionEntity getActiveSessionEntity(Long sessionId) {
        return this.studySessionRepository
                .findByIdAndDeletedAtIsNull(sessionId)
                .orElseThrow(() -> new StudySessionNotFoundException(sessionId));
    }
}

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
import com.learn.wire.entity.StudySessionModeStateEntity;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.DeckNotFoundException;
import com.learn.wire.exception.StudySessionNotFoundException;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.StudySessionRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
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
    private final StudySessionModeStateRepository studySessionModeStateRepository;
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
        if (flashcards.isEmpty()) {
            throw new BusinessException(StudyConst.DECK_HAS_NO_FLASHCARDS_KEY, command.deckId());
        }
        final StudySessionEntity session = upsertActiveSession(command);
        final StudyMode mode = command.mode();
        final StudySessionModeStateEntity modeState = upsertModeState(session, mode);
        final StudyModeEngine engine = this.studyEngineFactory.getEngine(mode);
        if (isModeStateInitialized(modeState)) {
            return engine.buildResponse(session, modeState);
        }
        engine.initializeSession(session, modeState, flashcards);
        final StudySessionModeStateEntity initializedModeState = getModeStateEntity(session.getId(), mode);
        return engine.buildResponse(session, initializedModeState);
    }

    @Override
    @Transactional(readOnly = true)
    public StudySessionResponse getSession(Long sessionId) {
        final StudySessionEntity session = getSessionEntity(sessionId);
        final StudyMode mode = resolveActiveMode(session);
        final StudySessionModeStateEntity modeState = getModeStateEntity(session.getId(), mode);
        final StudyModeEngine engine = this.studyEngineFactory.getEngine(mode);
        return engine.buildResponse(session, modeState);
    }

    @Override
    public StudySessionResponse submitEvent(Long sessionId, StudySessionEventRequest request) {
        final StudySessionEventCommand command = StudySessionEventCommand.fromRequest(request);
        final StudySessionEntity session = getSessionEntity(sessionId);
        final StudyMode mode = resolveActiveMode(session);
        final StudySessionModeStateEntity modeState = getModeStateEntity(session.getId(), mode);
        final StudyModeEngine engine = this.studyEngineFactory.getEngine(mode);
        return engine.handleEvent(session, modeState, command);
    }

    @Override
    public StudySessionResponse completeSession(Long sessionId) {
        final StudySessionEntity session = getSessionEntity(sessionId);
        final StudyMode mode = resolveActiveMode(session);
        final StudySessionModeStateEntity modeState = getModeStateEntity(session.getId(), mode);
        if (StudyConst.SESSION_STATUS_ACTIVE.equalsIgnoreCase(modeState.getStatus())) {
            markModeStateCompleted(modeState);
            this.studySessionModeStateRepository.save(modeState);
        }
        if (!shouldCompleteSession(session)) {
            return this.studyEngineFactory.getEngine(mode).buildResponse(session, modeState);
        }
        if (StudyConst.SESSION_STATUS_ACTIVE.equalsIgnoreCase(session.getStatus())) {
            session.setStatus(StudyConst.SESSION_STATUS_COMPLETED);
            session.setCompletedAt(Instant.now());
            session.setUpdatedBy(StudyConst.DEFAULT_ACTOR);
            this.studySessionRepository.save(session);
        }
        final StudySessionEntity completedSession = getSessionEntity(sessionId);
        return this.studyEngineFactory.getEngine(mode).buildResponse(completedSession, modeState);
    }

    private boolean shouldCompleteSession(StudySessionEntity session) {
        final long completedModeCount = this.studySessionModeStateRepository.countBySessionIdAndStatus(
                session.getId(),
                StudyConst.SESSION_STATUS_COMPLETED);
        return completedModeCount >= StudyMode.values().length;
    }

    private void markModeStateCompleted(StudySessionModeStateEntity modeState) {
        modeState.setStatus(StudyConst.SESSION_STATUS_COMPLETED);
        modeState.setCompletedAt(Instant.now());
    }

    private boolean isModeStateInitialized(StudySessionModeStateEntity modeState) {
        return modeState.getTotalUnits() > StudyConst.DEFAULT_INDEX;
    }

    private StudySessionEntity upsertActiveSession(StudySessionStartCommand command) {
        if (command.forceReset()) {
            completeActiveSession(command.deckId());
            final StudySessionEntity resetSession = createSession(command);
            resetSession.setActiveMode(command.mode().value());
            resetSession.setUpdatedBy(StudyConst.DEFAULT_ACTOR);
            return this.studySessionRepository.save(resetSession);
        }
        final StudySessionEntity session = this.studySessionRepository
                .findFirstByDeckIdAndStatusAndDeletedAtIsNullOrderByStartedAtDesc(
                        command.deckId(),
                        StudyConst.SESSION_STATUS_ACTIVE)
                .orElseGet(() -> createSession(command));
        session.setActiveMode(command.mode().value());
        session.setUpdatedBy(StudyConst.DEFAULT_ACTOR);
        return this.studySessionRepository.save(session);
    }

    private void completeActiveSession(Long deckId) {
        final StudySessionEntity activeSession = this.studySessionRepository
                .findFirstByDeckIdAndStatusAndDeletedAtIsNullOrderByStartedAtDesc(
                        deckId,
                        StudyConst.SESSION_STATUS_ACTIVE)
                .orElse(null);
        if (activeSession == null) {
            return;
        }
        activeSession.setStatus(StudyConst.SESSION_STATUS_COMPLETED);
        activeSession.setCompletedAt(Instant.now());
        activeSession.setUpdatedBy(StudyConst.DEFAULT_ACTOR);
        this.studySessionRepository.save(activeSession);
    }

    private StudySessionModeStateEntity upsertModeState(StudySessionEntity session, StudyMode mode) {
        return this.studySessionModeStateRepository
                .findBySessionIdAndMode(session.getId(), mode.value())
                .orElseGet(() -> createModeState(session, mode));
    }

    private StudySessionModeStateEntity createModeState(StudySessionEntity session, StudyMode mode) {
        final StudySessionModeStateEntity modeState = new StudySessionModeStateEntity();
        modeState.setSessionId(session.getId());
        modeState.setMode(mode.value());
        modeState.setStatus(StudyConst.SESSION_STATUS_ACTIVE);
        modeState.setCurrentIndex(StudyConst.DEFAULT_INDEX);
        modeState.setTotalUnits(StudyConst.DEFAULT_INDEX);
        modeState.setCorrectCount(StudyConst.ZERO_SCORE);
        modeState.setWrongCount(StudyConst.ZERO_SCORE);
        modeState.setStartedAt(Instant.now());
        return this.studySessionModeStateRepository.save(modeState);
    }

    private StudySessionEntity createSession(StudySessionStartCommand command) {
        final StudySessionEntity session = new StudySessionEntity();
        session.setDeckId(command.deckId());
        session.setActiveMode(command.mode().value());
        session.setStatus(StudyConst.SESSION_STATUS_ACTIVE);
        session.setSeed(command.seed());
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

    private StudySessionEntity getSessionEntity(Long sessionId) {
        return this.studySessionRepository
                .findByIdAndDeletedAtIsNull(sessionId)
                .orElseThrow(() -> new StudySessionNotFoundException(sessionId));
    }

    private StudyMode resolveActiveMode(StudySessionEntity session) {
        return StudyMode.fromValue(session.getActiveMode());
    }

    private StudySessionModeStateEntity getModeStateEntity(Long sessionId, StudyMode mode) {
        return this.studySessionModeStateRepository
                .findBySessionIdAndMode(sessionId, mode.value())
                .orElseThrow(() -> new StudySessionNotFoundException(sessionId));
    }
}

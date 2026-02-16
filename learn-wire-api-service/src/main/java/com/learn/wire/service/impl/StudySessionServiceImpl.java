package com.learn.wire.service.impl;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

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
import com.learn.wire.entity.StudySessionItemEntity;
import com.learn.wire.entity.StudySessionModeStateEntity;
import com.learn.wire.entity.StudySessionSnapshotItemEntity;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.DeckNotFoundException;
import com.learn.wire.exception.StudySessionNotFoundException;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
import com.learn.wire.repository.StudySessionSnapshotItemRepository;
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
    private final StudySessionItemRepository studySessionItemRepository;
    private final StudySessionSnapshotItemRepository studySessionSnapshotItemRepository;
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
        final StudySessionEntity session = upsertActiveSession(command);
        final StudyMode mode = resolveStartMode(session, command.mode(), command.forceReset());
        updateActiveMode(session, mode);
        final StudySessionModeStateEntity modeState = upsertModeState(session, mode);
        final StudyModeEngine engine = this.studyEngineFactory.getEngine(mode);
        if (isModeStateInitialized(modeState)) {
            return engine.buildResponse(session, modeState);
        }
        final List<FlashcardEntity> sessionSnapshotFlashcards = resolveSessionSnapshotFlashcards(session);
        engine.initializeSession(session, modeState, sessionSnapshotFlashcards);
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
            return this.studySessionRepository.save(resetSession);
        }
        return this.studySessionRepository
                .findFirstByDeckIdAndStatusAndDeletedAtIsNullOrderByStartedAtDesc(
                        command.deckId(),
                        StudyConst.SESSION_STATUS_ACTIVE)
                .orElseGet(() -> this.studySessionRepository.save(createSession(command)));
    }

    private StudyMode resolveStartMode(StudySessionEntity session, StudyMode requestedMode, boolean forceReset) {
        if (forceReset) {
            return requestedMode;
        }
        final List<StudySessionModeStateEntity> modeStates = this.studySessionModeStateRepository.findBySessionId(session.getId());
        if (modeStates.isEmpty()) {
            return requestedMode;
        }
        final Map<StudyMode, StudySessionModeStateEntity> modeStateByMode = buildModeStateByMode(modeStates);
        final List<StudyMode> modeCycle = buildModeCycle(requestedMode);
        for (final StudyMode candidate : modeCycle) {
            final StudySessionModeStateEntity candidateModeState = modeStateByMode.get(candidate);
            if (candidateModeState == null) {
                return candidate;
            }
            if (!isModeStateCompleted(candidateModeState)) {
                return candidate;
            }
        }
        return requestedMode;
    }

    private Map<StudyMode, StudySessionModeStateEntity> buildModeStateByMode(List<StudySessionModeStateEntity> modeStates) {
        final Map<StudyMode, StudySessionModeStateEntity> modeStateByMode = new EnumMap<>(StudyMode.class);
        for (final StudySessionModeStateEntity modeState : modeStates) {
            modeStateByMode.put(StudyMode.fromValue(modeState.getMode()), modeState);
        }
        return modeStateByMode;
    }

    private List<StudyMode> buildModeCycle(StudyMode startMode) {
        final StudyMode[] allModes = StudyMode.values();
        final int modeCount = allModes.length;
        final List<StudyMode> modeCycle = new ArrayList<>(modeCount);
        int offset = StudyConst.DEFAULT_INDEX;
        while (offset < modeCount) {
            final int cycleIndex = (startMode.ordinal() + offset) % modeCount;
            modeCycle.add(allModes[cycleIndex]);
            offset++;
        }
        return modeCycle;
    }

    private boolean isModeStateCompleted(StudySessionModeStateEntity modeState) {
        return StudyConst.SESSION_STATUS_COMPLETED.equalsIgnoreCase(modeState.getStatus());
    }

    private void updateActiveMode(StudySessionEntity session, StudyMode mode) {
        session.setActiveMode(mode.value());
        session.setUpdatedBy(StudyConst.DEFAULT_ACTOR);
        this.studySessionRepository.save(session);
    }

    private List<FlashcardEntity> resolveSessionSnapshotFlashcards(StudySessionEntity session) {
        final List<StudySessionSnapshotItemEntity> snapshotItems = this.studySessionSnapshotItemRepository
                .findBySessionIdOrderByItemOrderAsc(session.getId());
        if (!snapshotItems.isEmpty()) {
            return mapSnapshotItemsToFlashcards(snapshotItems, session.getDeckId());
        }
        final List<StudySessionSnapshotItemEntity> initializedSnapshotItems = initializeSessionSnapshotItems(session);
        return mapSnapshotItemsToFlashcards(initializedSnapshotItems, session.getDeckId());
    }

    private List<StudySessionSnapshotItemEntity> initializeSessionSnapshotItems(StudySessionEntity session) {
        final List<StudySessionItemEntity> existingLinearItems = findExistingLinearSessionItems(session.getId());
        if (!existingLinearItems.isEmpty()) {
            final List<StudySessionSnapshotItemEntity> snapshotItems = mapLinearItemsToSnapshotItems(
                    session.getId(),
                    existingLinearItems);
            return this.studySessionSnapshotItemRepository.saveAll(snapshotItems);
        }
        final List<FlashcardEntity> deckFlashcards = this.flashcardRepository
                .findByDeckIdAndDeletedAtIsNull(session.getDeckId());
        if (deckFlashcards.isEmpty()) {
            throw new BusinessException(StudyConst.DECK_HAS_NO_FLASHCARDS_KEY, session.getDeckId());
        }
        final List<FlashcardEntity> shuffledFlashcards = shuffleFlashcards(deckFlashcards, session.getSeed());
        final List<StudySessionSnapshotItemEntity> snapshotItems = mapFlashcardsToSnapshotItems(
                session.getId(),
                shuffledFlashcards);
        return this.studySessionSnapshotItemRepository.saveAll(snapshotItems);
    }

    private List<StudySessionItemEntity> findExistingLinearSessionItems(Long sessionId) {
        final List<StudyMode> linearModes = buildLinearModes();
        for (final StudyMode mode : linearModes) {
            final StudySessionModeStateEntity modeState = this.studySessionModeStateRepository
                    .findBySessionIdAndMode(sessionId, mode.value())
                    .orElse(null);
            if (modeState == null) {
                continue;
            }
            if (!isModeStateInitialized(modeState)) {
                continue;
            }
            final List<StudySessionItemEntity> modeItems = this.studySessionItemRepository
                    .findByModeStateIdOrderByItemOrderAsc(modeState.getId());
            if (!modeItems.isEmpty()) {
                return modeItems;
            }
        }
        return List.of();
    }

    private List<StudyMode> buildLinearModes() {
        final List<StudyMode> linearModes = new ArrayList<>();
        for (final StudyMode mode : StudyMode.values()) {
            if (mode == StudyMode.MATCH) {
                continue;
            }
            linearModes.add(mode);
        }
        return linearModes;
    }

    private List<StudySessionSnapshotItemEntity> mapLinearItemsToSnapshotItems(
            Long sessionId,
            List<StudySessionItemEntity> linearItems) {
        final List<StudySessionSnapshotItemEntity> snapshotItems = new ArrayList<>();
        for (final StudySessionItemEntity linearItem : linearItems) {
            final StudySessionSnapshotItemEntity snapshotItem = new StudySessionSnapshotItemEntity();
            snapshotItem.setSessionId(sessionId);
            snapshotItem.setFlashcardId(linearItem.getFlashcardId());
            snapshotItem.setItemOrder(linearItem.getItemOrder());
            snapshotItem.setFrontText(linearItem.getFrontText());
            snapshotItem.setBackText(linearItem.getBackText());
            snapshotItems.add(snapshotItem);
        }
        return snapshotItems;
    }

    private List<StudySessionSnapshotItemEntity> mapFlashcardsToSnapshotItems(
            Long sessionId,
            List<FlashcardEntity> flashcards) {
        final List<StudySessionSnapshotItemEntity> snapshotItems = new ArrayList<>();
        int itemOrder = StudyConst.DEFAULT_INDEX;
        for (final FlashcardEntity flashcard : flashcards) {
            final StudySessionSnapshotItemEntity snapshotItem = new StudySessionSnapshotItemEntity();
            snapshotItem.setSessionId(sessionId);
            snapshotItem.setFlashcardId(flashcard.getId());
            snapshotItem.setItemOrder(itemOrder);
            snapshotItem.setFrontText(flashcard.getFrontText());
            snapshotItem.setBackText(flashcard.getBackText());
            snapshotItems.add(snapshotItem);
            itemOrder++;
        }
        return snapshotItems;
    }

    private List<FlashcardEntity> mapSnapshotItemsToFlashcards(
            List<StudySessionSnapshotItemEntity> snapshotItems,
            Long deckId) {
        final List<FlashcardEntity> flashcards = new ArrayList<>();
        for (final StudySessionSnapshotItemEntity snapshotItem : snapshotItems) {
            final FlashcardEntity flashcard = new FlashcardEntity();
            flashcard.setId(snapshotItem.getFlashcardId());
            flashcard.setDeckId(deckId);
            flashcard.setFrontText(snapshotItem.getFrontText());
            flashcard.setBackText(snapshotItem.getBackText());
            flashcards.add(flashcard);
        }
        return flashcards;
    }

    private List<FlashcardEntity> shuffleFlashcards(List<FlashcardEntity> flashcards, int seed) {
        final List<FlashcardEntity> shuffledFlashcards = new ArrayList<>(flashcards);
        Collections.shuffle(shuffledFlashcards, new Random(seed));
        return shuffledFlashcards;
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

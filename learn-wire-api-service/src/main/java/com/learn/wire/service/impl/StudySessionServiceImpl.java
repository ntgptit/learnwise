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

import com.learn.wire.constant.AuthConst;
import com.learn.wire.constant.LogConst;
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
import com.learn.wire.repository.AppUserRepository;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
import com.learn.wire.repository.StudySessionRepository;
import com.learn.wire.repository.StudySessionSnapshotItemRepository;
import com.learn.wire.security.CurrentUserAccessor;
import com.learn.wire.service.StudySessionService;
import com.learn.wire.service.factory.StudyEngineFactory;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class StudySessionServiceImpl implements StudySessionService {

    private static final int STUDY_CARDS_PER_SESSION_DEFAULT = AuthConst.STUDY_CARDS_PER_SESSION_DEFAULT;
    private static final int STUDY_CARDS_PER_SESSION_MIN = AuthConst.STUDY_CARDS_PER_SESSION_MIN;
    private static final int STUDY_CARDS_PER_SESSION_MAX = AuthConst.STUDY_CARDS_PER_SESSION_MAX;

    private final AppUserRepository appUserRepository;
    private final DeckRepository deckRepository;
    private final FlashcardRepository flashcardRepository;
    private final StudySessionRepository studySessionRepository;
    private final StudySessionModeStateRepository studySessionModeStateRepository;
    private final StudySessionItemRepository studySessionItemRepository;
    private final StudySessionSnapshotItemRepository studySessionSnapshotItemRepository;
    private final StudyEngineFactory studyEngineFactory;
    private final CurrentUserAccessor currentUserAccessor;

    @Override
    public StudySessionResponse startSession(Long deckId, StudySessionStartRequest request) {
        final var currentUserId = this.currentUserAccessor.getCurrentUserId();
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        final var command = StudySessionStartCommand.fromRequest(deckId, request);
        log.debug(
                LogConst.STUDY_SERVICE_START_SESSION,
                command.deckId(),
                command.mode().value(),
                command.seed());
        getActiveDeckEntity(command.deckId(), currentActor);
        final var session = upsertActiveSession(command, currentActor);
        final var mode = resolveStartMode(session, command.mode(), command.forceReset());
        updateActiveMode(session, mode, currentActor);
        final var modeState = upsertModeState(session, mode);
        final var engine = this.studyEngineFactory.getEngine(mode);
        if (isModeStateInitialized(modeState)) {
            return engine.buildResponse(session, modeState);
        }
        final var sessionSnapshotFlashcards = resolveSessionSnapshotFlashcards(session, currentActor, currentUserId);
        engine.initializeSession(session, modeState, sessionSnapshotFlashcards);
        final var initializedModeState = getModeStateEntity(session.getId(), mode);
        return engine.buildResponse(session, initializedModeState);
    }

    @Override
    @Transactional(readOnly = true)
    public StudySessionResponse getSession(Long sessionId) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        final var session = getSessionEntity(sessionId, currentActor);
        final var mode = resolveActiveMode(session);
        final var modeState = getModeStateEntity(session.getId(), mode);
        final var engine = this.studyEngineFactory.getEngine(mode);
        return engine.buildResponse(session, modeState);
    }

    @Override
    public StudySessionResponse submitEvent(Long sessionId, StudySessionEventRequest request) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        final var command = StudySessionEventCommand.fromRequest(request);
        final var session = getSessionEntity(sessionId, currentActor);
        final var mode = resolveActiveMode(session);
        final var modeState = getModeStateEntity(session.getId(), mode);
        final var engine = this.studyEngineFactory.getEngine(mode);
        return engine.handleEvent(session, modeState, command);
    }

    @Override
    public StudySessionResponse completeSession(Long sessionId) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        final var session = getSessionEntity(sessionId, currentActor);
        final var mode = resolveActiveMode(session);
        final var modeState = getModeStateEntity(session.getId(), mode);
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
            session.setUpdatedBy(currentActor);
            this.studySessionRepository.save(session);
        }
        final var completedSession = getSessionEntity(sessionId, currentActor);
        return this.studyEngineFactory.getEngine(mode).buildResponse(completedSession, modeState);
    }

    private boolean shouldCompleteSession(StudySessionEntity session) {
        final var completedModeCount = this.studySessionModeStateRepository.countBySessionIdAndStatus(
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

    private StudySessionEntity upsertActiveSession(StudySessionStartCommand command, String currentActor) {
        if (command.forceReset()) {
            completeActiveSession(command.deckId(), currentActor);
            final var resetSession = createSession(command, currentActor);
            return this.studySessionRepository.save(resetSession);
        }
        return this.studySessionRepository
                .findFirstByDeckIdAndStatusAndDeletedAtIsNullAndCreatedByOrderByStartedAtDesc(
                        command.deckId(),
                        StudyConst.SESSION_STATUS_ACTIVE,
                        currentActor)
                .orElseGet(() -> this.studySessionRepository.save(createSession(command, currentActor)));
    }

    private StudyMode resolveStartMode(StudySessionEntity session, StudyMode requestedMode, boolean forceReset) {
        if (forceReset) {
            return requestedMode;
        }
        final var modeStates = this.studySessionModeStateRepository.findBySessionId(
                session.getId());
        if (modeStates.isEmpty()) {
            return requestedMode;
        }
        final var modeStateByMode = buildModeStateByMode(modeStates);
        final var modeCycle = buildModeCycle(requestedMode);
        for (final StudyMode candidate : modeCycle) {
            final var candidateModeState = modeStateByMode.get(candidate);
            if ((candidateModeState == null) || !isModeStateCompleted(candidateModeState)) {
                return candidate;
            }
        }
        return requestedMode;
    }

    private Map<StudyMode, StudySessionModeStateEntity> buildModeStateByMode(
            List<StudySessionModeStateEntity> modeStates) {
        final Map<StudyMode, StudySessionModeStateEntity> modeStateByMode = new EnumMap<>(StudyMode.class);
        for (final StudySessionModeStateEntity modeState : modeStates) {
            modeStateByMode.put(StudyMode.fromValue(modeState.getMode()), modeState);
        }
        return modeStateByMode;
    }

    private List<StudyMode> buildModeCycle(StudyMode startMode) {
        final var allModes = StudyMode.values();
        final var modeCount = allModes.length;
        final List<StudyMode> modeCycle = new ArrayList<>(modeCount);
        var offset = StudyConst.DEFAULT_INDEX;
        while (offset < modeCount) {
            final var cycleIndex = (startMode.ordinal() + offset) % modeCount;
            modeCycle.add(allModes[cycleIndex]);
            offset++;
        }
        return modeCycle;
    }

    private boolean isModeStateCompleted(StudySessionModeStateEntity modeState) {
        return StudyConst.SESSION_STATUS_COMPLETED.equalsIgnoreCase(modeState.getStatus());
    }

    private void updateActiveMode(StudySessionEntity session, StudyMode mode, String currentActor) {
        session.setActiveMode(mode.value());
        session.setUpdatedBy(currentActor);
        this.studySessionRepository.save(session);
    }

    private List<FlashcardEntity> resolveSessionSnapshotFlashcards(
            StudySessionEntity session,
            String currentActor,
            Long currentUserId) {
        final var snapshotItems = this.studySessionSnapshotItemRepository
                .findBySessionIdOrderByItemOrderAsc(session.getId());
        if (!snapshotItems.isEmpty()) {
            return mapSnapshotItemsToFlashcards(snapshotItems, session.getDeckId());
        }
        final var initializedSnapshotItems = initializeSessionSnapshotItems(
                session,
                currentActor,
                currentUserId);
        return mapSnapshotItemsToFlashcards(initializedSnapshotItems, session.getDeckId());
    }

    private List<StudySessionSnapshotItemEntity> initializeSessionSnapshotItems(
            StudySessionEntity session,
            String currentActor,
            Long currentUserId) {
        final var existingLinearItems = findExistingLinearSessionItems(session.getId());
        if (!existingLinearItems.isEmpty()) {
            final var snapshotItems = mapLinearItemsToSnapshotItems(
                    session.getId(),
                    existingLinearItems);
            return this.studySessionSnapshotItemRepository.saveAll(snapshotItems);
        }
        final var deckFlashcards = this.flashcardRepository
                .findByDeckIdAndCreatedByAndDeletedAtIsNull(session.getDeckId(), currentActor);
        if (deckFlashcards.isEmpty()) {
            throw new BusinessException(StudyConst.DECK_HAS_NO_FLASHCARDS_KEY, session.getDeckId());
        }
        final var shuffledFlashcards = shuffleFlashcards(deckFlashcards, session.getSeed());
        final var cardsPerSession = resolveCardsPerSession(currentUserId);
        final var snapshotFlashcards = limitFlashcardsByCardsPerSession(shuffledFlashcards, cardsPerSession);
        final var snapshotItems = mapFlashcardsToSnapshotItems(
                session.getId(),
                snapshotFlashcards);
        return this.studySessionSnapshotItemRepository.saveAll(snapshotItems);
    }

    private int resolveCardsPerSession(Long userId) {
        return this.appUserRepository
                .findById(userId)
                .map(user -> normalizeCardsPerSession(user.getStudyCardsPerSession()))
                .orElse(STUDY_CARDS_PER_SESSION_DEFAULT);
    }

    private int normalizeCardsPerSession(Integer rawValue) {
        if (rawValue == null) {
            return STUDY_CARDS_PER_SESSION_DEFAULT;
        }
        if (rawValue < STUDY_CARDS_PER_SESSION_MIN) {
            return STUDY_CARDS_PER_SESSION_MIN;
        }
        if (rawValue > STUDY_CARDS_PER_SESSION_MAX) {
            return STUDY_CARDS_PER_SESSION_MAX;
        }
        return rawValue;
    }

    private List<FlashcardEntity> limitFlashcardsByCardsPerSession(
            List<FlashcardEntity> flashcards,
            int cardsPerSession) {
        if (flashcards.size() <= cardsPerSession) {
            return flashcards;
        }
        return new ArrayList<>(flashcards.subList(StudyConst.DEFAULT_INDEX, cardsPerSession));
    }

    private List<StudySessionItemEntity> findExistingLinearSessionItems(Long sessionId) {
        final var linearModes = buildLinearModes();
        for (final StudyMode mode : linearModes) {
            final var modeState = this.studySessionModeStateRepository
                    .findBySessionIdAndMode(sessionId, mode.value())
                    .orElse(null);
            if ((modeState == null) || !isModeStateInitialized(modeState)) {
                continue;
            }
            final var modeItems = this.studySessionItemRepository
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
            final var snapshotItem = new StudySessionSnapshotItemEntity();
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
        var itemOrder = StudyConst.DEFAULT_INDEX;
        for (final FlashcardEntity flashcard : flashcards) {
            final var snapshotItem = new StudySessionSnapshotItemEntity();
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
            final var flashcard = new FlashcardEntity();
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

    private void completeActiveSession(Long deckId, String currentActor) {
        final var activeSession = this.studySessionRepository
                .findFirstByDeckIdAndStatusAndDeletedAtIsNullAndCreatedByOrderByStartedAtDesc(
                        deckId,
                        StudyConst.SESSION_STATUS_ACTIVE,
                        currentActor)
                .orElse(null);
        if (activeSession == null) {
            return;
        }
        activeSession.setStatus(StudyConst.SESSION_STATUS_COMPLETED);
        activeSession.setCompletedAt(Instant.now());
        activeSession.setUpdatedBy(currentActor);
        this.studySessionRepository.save(activeSession);
    }

    private StudySessionModeStateEntity upsertModeState(StudySessionEntity session, StudyMode mode) {
        return this.studySessionModeStateRepository
                .findBySessionIdAndMode(session.getId(), mode.value())
                .orElseGet(() -> createModeState(session, mode));
    }

    private StudySessionModeStateEntity createModeState(StudySessionEntity session, StudyMode mode) {
        final var modeState = new StudySessionModeStateEntity();
        modeState.setSessionId(session.getId());
        modeState.setMode(mode.value());
        modeState.setStatus(StudyConst.SESSION_STATUS_ACTIVE);
        modeState.setCurrentIndex(StudyConst.DEFAULT_INDEX);
        modeState.setTotalUnits(StudyConst.DEFAULT_INDEX);
        modeState.setStartedAt(Instant.now());
        return this.studySessionModeStateRepository.save(modeState);
    }

    private StudySessionEntity createSession(StudySessionStartCommand command, String currentActor) {
        final var session = new StudySessionEntity();
        session.setDeckId(command.deckId());
        session.setActiveMode(command.mode().value());
        session.setStatus(StudyConst.SESSION_STATUS_ACTIVE);
        session.setSeed(command.seed());
        session.setStartedAt(Instant.now());
        session.setCreatedBy(currentActor);
        session.setUpdatedBy(currentActor);
        return session;
    }

    private DeckEntity getActiveDeckEntity(Long deckId, String currentActor) {
        return this.deckRepository
                .findByIdAndCreatedByAndDeletedAtIsNull(deckId, currentActor)
                .orElseThrow(() -> new DeckNotFoundException(deckId));
    }

    private StudySessionEntity getSessionEntity(Long sessionId, String currentActor) {
        return this.studySessionRepository
                .findByIdAndDeletedAtIsNullAndCreatedBy(sessionId, currentActor)
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

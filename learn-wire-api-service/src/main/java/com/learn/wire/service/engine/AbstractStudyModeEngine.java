package com.learn.wire.service.engine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.dto.study.query.StudySessionEventCommand;
import com.learn.wire.dto.study.response.StudyAttemptResultResponse;
import com.learn.wire.dto.study.response.StudyMatchTileResponse;
import com.learn.wire.dto.study.response.StudyReviewItemResponse;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.StudyAttemptEntity;
import com.learn.wire.entity.StudySessionEntity;
import com.learn.wire.entity.StudySessionModeStateEntity;
import com.learn.wire.entity.StudySessionItemEntity;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.repository.StudyAttemptRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionRepository;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public abstract class AbstractStudyModeEngine implements StudyModeEngine {

    protected final StudySessionRepository studySessionRepository;
    protected final StudySessionModeStateRepository studySessionModeStateRepository;
    protected final StudySessionItemRepository studySessionItemRepository;
    protected final StudyAttemptRepository studyAttemptRepository;

    @Override
    public final StudySessionResponse buildResponse(StudySessionEntity session, StudySessionModeStateEntity modeState) {
        return buildResponseInternal(session, modeState);
    }

    @Override
    public final StudySessionResponse handleEvent(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState,
            StudySessionEventCommand command) {
        requireActiveSession(session);
        requireActiveModeState(modeState);
        validateSupportedEvent(command);
        if (isDuplicateEvent(modeState.getId(), command.clientEventId())) {
            return buildResponse(session, modeState);
        }
        final StudyAttemptEntity attempt = createAttempt(modeState, command);
        handleEventInternal(session, modeState, command, attempt);
        this.studySessionRepository.save(session);
        this.studySessionModeStateRepository.save(modeState);
        this.studyAttemptRepository.save(attempt);
        return buildResponse(session, modeState);
    }

    protected abstract void validateSupportedEvent(StudySessionEventCommand command);

    protected abstract void handleEventInternal(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState,
            StudySessionEventCommand command,
            StudyAttemptEntity attempt);

    protected abstract StudySessionResponse buildResponseInternal(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState);

    protected void requireActiveSession(StudySessionEntity session) {
        if (StudyConst.SESSION_STATUS_ACTIVE.equalsIgnoreCase(session.getStatus())) {
            return;
        }
        throw new BusinessException(StudyConst.SESSION_NOT_ACTIVE_KEY, session.getId());
    }

    protected void requireActiveModeState(StudySessionModeStateEntity modeState) {
        if (StudyConst.SESSION_STATUS_ACTIVE.equalsIgnoreCase(modeState.getStatus())) {
            return;
        }
        throw new BusinessException(StudyConst.SESSION_NOT_ACTIVE_KEY, modeState.getSessionId());
    }

    protected List<FlashcardEntity> shuffleFlashcards(List<FlashcardEntity> flashcards, int seed) {
        final List<FlashcardEntity> shuffled = new ArrayList<>(flashcards);
        Collections.shuffle(shuffled, new Random(seed));
        return shuffled;
    }

    protected List<StudySessionItemEntity> createSessionItems(Long modeStateId, List<FlashcardEntity> flashcards) {
        final List<StudySessionItemEntity> items = new ArrayList<>();
        int order = StudyConst.DEFAULT_INDEX;
        for (final FlashcardEntity flashcard : flashcards) {
            final StudySessionItemEntity item = new StudySessionItemEntity();
            item.setModeStateId(modeStateId);
            item.setFlashcardId(flashcard.getId());
            item.setItemOrder(order);
            item.setFrontText(flashcard.getFrontText());
            item.setBackText(flashcard.getBackText());
            items.add(item);
            order++;
        }
        return items;
    }

    protected List<StudyReviewItemResponse> loadReviewItems(Long modeStateId) {
        final List<StudySessionItemEntity> sessionItems =
                this.studySessionItemRepository.findByModeStateIdOrderByItemOrderAsc(modeStateId);
        final List<StudyReviewItemResponse> responses = new ArrayList<>();
        for (final StudySessionItemEntity sessionItem : sessionItems) {
            responses.add(new StudyReviewItemResponse(
                    sessionItem.getId(),
                    sessionItem.getFlashcardId(),
                    sessionItem.getItemOrder(),
                    sessionItem.getFrontText(),
                    sessionItem.getBackText()));
        }
        return responses;
    }

    protected StudySessionResponse buildLinearResponse(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState) {
        final List<StudyReviewItemResponse> reviewItems = loadReviewItems(modeState.getId());
        return buildSessionResponse(
                session,
                modeState,
                reviewItems,
                List.of(),
                List.of(),
                null);
    }

    protected StudySessionResponse buildSessionResponse(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState,
            List<StudyReviewItemResponse> reviewItems,
            List<StudyMatchTileResponse> leftTiles,
            List<StudyMatchTileResponse> rightTiles,
            StudyAttemptResultResponse lastAttemptResult) {
        final int completedModeCount = resolveCompletedModeCount(session.getId());
        final int requiredModeCount = resolveRequiredModeCount();
        final boolean sessionCompleted = StudyConst.SESSION_STATUS_COMPLETED.equalsIgnoreCase(session.getStatus());
        return new StudySessionResponse(
                session.getId(),
                session.getDeckId(),
                modeState.getMode(),
                session.getStatus(),
                modeState.getCurrentIndex(),
                modeState.getTotalUnits(),
                modeState.getCorrectCount(),
                modeState.getWrongCount(),
                isModeCompleted(modeState),
                session.getStartedAt(),
                modeState.getCompletedAt(),
                reviewItems,
                leftTiles,
                rightTiles,
                lastAttemptResult,
                completedModeCount,
                requiredModeCount,
                sessionCompleted);
    }

    protected int clampIndex(int targetIndex, int totalUnits) {
        if (totalUnits <= StudyConst.DEFAULT_INDEX) {
            return StudyConst.DEFAULT_INDEX;
        }
        final int lastIndex = totalUnits - 1;
        if (targetIndex <= StudyConst.DEFAULT_INDEX) {
            return StudyConst.DEFAULT_INDEX;
        }
        if (targetIndex >= lastIndex) {
            return lastIndex;
        }
        return targetIndex;
    }

    protected int resolveRequiredModeCount() {
        return StudyMode.values().length;
    }

    protected int resolveCompletedModeCount(Long sessionId) {
        final long completedModeCount = this.studySessionModeStateRepository.countBySessionIdAndStatus(
                sessionId,
                StudyConst.SESSION_STATUS_COMPLETED);
        return (int) completedModeCount;
    }

    private boolean isDuplicateEvent(Long modeStateId, String clientEventId) {
        return this.studyAttemptRepository.findByModeStateIdAndClientEventId(modeStateId, clientEventId).isPresent();
    }

    private StudyAttemptEntity createAttempt(StudySessionModeStateEntity modeState, StudySessionEventCommand command) {
        final StudyAttemptEntity attempt = new StudyAttemptEntity();
        attempt.setModeStateId(modeState.getId());
        attempt.setClientEventId(command.clientEventId());
        attempt.setClientSequence(command.clientSequence());
        attempt.setEventType(command.eventType().value());
        attempt.setTargetIndex(command.targetIndex());
        attempt.setTargetTileId(command.targetTileId());
        return attempt;
    }

    private boolean isModeCompleted(StudySessionModeStateEntity modeState) {
        return StudyConst.SESSION_STATUS_COMPLETED.equalsIgnoreCase(modeState.getStatus());
    }
}

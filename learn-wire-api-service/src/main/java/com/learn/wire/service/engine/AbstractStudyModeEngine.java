package com.learn.wire.service.engine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.query.StudySessionEventCommand;
import com.learn.wire.dto.study.response.StudyAttemptResultResponse;
import com.learn.wire.dto.study.response.StudyMatchTileResponse;
import com.learn.wire.dto.study.response.StudyReviewItemResponse;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.StudyAttemptEntity;
import com.learn.wire.entity.StudySessionEntity;
import com.learn.wire.entity.StudySessionItemEntity;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.repository.StudyAttemptRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionRepository;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
public abstract class AbstractStudyModeEngine implements StudyModeEngine {

    protected final StudySessionRepository studySessionRepository;
    protected final StudySessionItemRepository studySessionItemRepository;
    protected final StudyAttemptRepository studyAttemptRepository;

    @Override
    public final StudySessionResponse buildResponse(StudySessionEntity session) {
        return buildResponseInternal(session);
    }

    @Override
    public final StudySessionResponse handleEvent(StudySessionEntity session, StudySessionEventCommand command) {
        requireActiveSession(session);
        validateSupportedEvent(command);
        if (isDuplicateEvent(session.getId(), command.clientEventId())) {
            return buildResponse(session);
        }
        final StudyAttemptEntity attempt = createAttempt(session, command);
        handleEventInternal(session, command, attempt);
        this.studySessionRepository.save(session);
        this.studyAttemptRepository.save(attempt);
        return buildResponse(session);
    }

    protected abstract void validateSupportedEvent(StudySessionEventCommand command);

    protected abstract void handleEventInternal(
            StudySessionEntity session,
            StudySessionEventCommand command,
            StudyAttemptEntity attempt);

    protected abstract StudySessionResponse buildResponseInternal(StudySessionEntity session);

    protected void requireActiveSession(StudySessionEntity session) {
        if (StudyConst.SESSION_STATUS_ACTIVE.equalsIgnoreCase(session.getStatus())) {
            return;
        }
        throw new BusinessException(StudyConst.SESSION_NOT_ACTIVE_KEY, session.getId());
    }

    protected List<FlashcardEntity> shuffleFlashcards(List<FlashcardEntity> flashcards, int seed) {
        final List<FlashcardEntity> shuffled = new ArrayList<>(flashcards);
        Collections.shuffle(shuffled, new Random(seed));
        return shuffled;
    }

    protected List<StudySessionItemEntity> createSessionItems(Long sessionId, List<FlashcardEntity> flashcards) {
        final List<StudySessionItemEntity> items = new ArrayList<>();
        int order = StudyConst.DEFAULT_INDEX;
        for (final FlashcardEntity flashcard : flashcards) {
            final StudySessionItemEntity item = new StudySessionItemEntity();
            item.setSessionId(sessionId);
            item.setFlashcardId(flashcard.getId());
            item.setItemOrder(order);
            item.setFrontText(flashcard.getFrontText());
            item.setBackText(flashcard.getBackText());
            items.add(item);
            order++;
        }
        return items;
    }

    protected List<StudyReviewItemResponse> loadReviewItems(Long sessionId) {
        final List<StudySessionItemEntity> sessionItems =
                this.studySessionItemRepository.findBySessionIdOrderByItemOrderAsc(sessionId);
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

    protected StudySessionResponse buildLinearResponse(StudySessionEntity session) {
        final List<StudyReviewItemResponse> reviewItems = loadReviewItems(session.getId());
        return buildSessionResponse(
                session,
                reviewItems,
                List.of(),
                List.of(),
                null);
    }

    protected StudySessionResponse buildSessionResponse(
            StudySessionEntity session,
            List<StudyReviewItemResponse> reviewItems,
            List<StudyMatchTileResponse> leftTiles,
            List<StudyMatchTileResponse> rightTiles,
            StudyAttemptResultResponse lastAttemptResult) {
        return new StudySessionResponse(
                session.getId(),
                session.getDeckId(),
                session.getMode(),
                session.getStatus(),
                session.getCurrentIndex(),
                session.getTotalUnits(),
                session.getCorrectCount(),
                session.getWrongCount(),
                isCompleted(session),
                session.getStartedAt(),
                session.getCompletedAt(),
                reviewItems,
                leftTiles,
                rightTiles,
                lastAttemptResult);
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

    private boolean isDuplicateEvent(Long sessionId, String clientEventId) {
        return this.studyAttemptRepository.findBySessionIdAndClientEventId(sessionId, clientEventId).isPresent();
    }

    private StudyAttemptEntity createAttempt(StudySessionEntity session, StudySessionEventCommand command) {
        final StudyAttemptEntity attempt = new StudyAttemptEntity();
        attempt.setSessionId(session.getId());
        attempt.setClientEventId(command.clientEventId());
        attempt.setClientSequence(command.clientSequence());
        attempt.setEventType(command.eventType().value());
        attempt.setTargetIndex(command.targetIndex());
        attempt.setTargetTileId(command.targetTileId());
        return attempt;
    }

    private boolean isCompleted(StudySessionEntity session) {
        return StudyConst.SESSION_STATUS_COMPLETED.equalsIgnoreCase(session.getStatus());
    }
}

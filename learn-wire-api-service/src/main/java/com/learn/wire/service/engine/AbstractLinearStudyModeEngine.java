package com.learn.wire.service.engine;

import java.util.List;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.query.StudyEventType;
import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.dto.study.query.StudySessionEventCommand;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.StudyAttemptEntity;
import com.learn.wire.entity.StudySessionEntity;
import com.learn.wire.entity.StudySessionModeStateEntity;
import com.learn.wire.entity.StudySessionItemEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.StudyEventNotSupportedException;
import com.learn.wire.repository.StudyAttemptRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionRepository;

public abstract class AbstractLinearStudyModeEngine extends AbstractStudyModeEngine {

    private final StudyMode mode;

    protected AbstractLinearStudyModeEngine(
            StudyMode mode,
            StudySessionRepository studySessionRepository,
            StudySessionModeStateRepository studySessionModeStateRepository,
            StudySessionItemRepository studySessionItemRepository,
            StudyAttemptRepository studyAttemptRepository) {
        super(
                studySessionRepository,
                studySessionModeStateRepository,
                studySessionItemRepository,
                studyAttemptRepository);
        this.mode = mode;
    }

    @Override
    public final StudyMode mode() {
        return this.mode;
    }

    @Override
    public void initializeSession(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState,
            List<FlashcardEntity> flashcards) {
        final List<FlashcardEntity> shuffled = shuffleFlashcards(flashcards, session.getSeed());
        final List<StudySessionItemEntity> sessionItems = createSessionItems(modeState.getId(), shuffled);
        this.studySessionItemRepository.saveAll(sessionItems);
        modeState.setCurrentIndex(StudyConst.DEFAULT_INDEX);
        modeState.setTotalUnits(sessionItems.size());
        modeState.setCorrectCount(StudyConst.ZERO_SCORE);
        modeState.setWrongCount(StudyConst.ZERO_SCORE);
        this.studySessionModeStateRepository.save(modeState);
    }

    @Override
    protected final void validateSupportedEvent(StudySessionEventCommand command) {
        if (command.eventType().isLinearNavigation()) {
            return;
        }
        throw new StudyEventNotSupportedException(mode().value(), command.eventType().value());
    }

    @Override
    protected final void handleEventInternal(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState,
            StudySessionEventCommand command,
            StudyAttemptEntity attempt) {
        final StudyEventType eventType = command.eventType();
        if (eventType == StudyEventType.REVIEW_NEXT) {
            final int nextIndex = clampIndex(modeState.getCurrentIndex() + 1, modeState.getTotalUnits());
            modeState.setCurrentIndex(nextIndex);
            attempt.setTargetIndex(nextIndex);
            return;
        }
        if (eventType == StudyEventType.REVIEW_PREVIOUS) {
            final int previousIndex = clampIndex(modeState.getCurrentIndex() - 1, modeState.getTotalUnits());
            modeState.setCurrentIndex(previousIndex);
            attempt.setTargetIndex(previousIndex);
            return;
        }
        if (eventType == StudyEventType.REVIEW_GOTO_INDEX) {
            final int targetIndex = resolveTargetIndex(command.targetIndex(), modeState.getTotalUnits());
            modeState.setCurrentIndex(targetIndex);
            attempt.setTargetIndex(targetIndex);
            return;
        }
        throw new BadRequestException(StudyConst.EVENT_TYPE_INVALID_KEY);
    }

    @Override
    protected StudySessionResponse buildResponseInternal(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState) {
        return buildLinearResponse(session, modeState);
    }

    private int resolveTargetIndex(Integer targetIndex, int totalUnits) {
        if (targetIndex == null) {
            throw new BadRequestException(StudyConst.EVENT_TARGET_INDEX_INVALID_KEY);
        }
        if (totalUnits <= StudyConst.DEFAULT_INDEX && targetIndex == StudyConst.DEFAULT_INDEX) {
            return StudyConst.DEFAULT_INDEX;
        }
        if (targetIndex >= StudyConst.DEFAULT_INDEX && targetIndex < totalUnits) {
            return targetIndex;
        }
        throw new BadRequestException(StudyConst.EVENT_TARGET_INDEX_INVALID_KEY);
    }
}

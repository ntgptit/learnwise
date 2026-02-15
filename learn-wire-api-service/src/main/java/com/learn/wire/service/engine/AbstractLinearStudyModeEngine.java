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
import com.learn.wire.entity.StudySessionItemEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.StudyEventNotSupportedException;
import com.learn.wire.repository.StudyAttemptRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionRepository;

public abstract class AbstractLinearStudyModeEngine extends AbstractStudyModeEngine {

    private final StudyMode mode;

    protected AbstractLinearStudyModeEngine(
            StudyMode mode,
            StudySessionRepository studySessionRepository,
            StudySessionItemRepository studySessionItemRepository,
            StudyAttemptRepository studyAttemptRepository) {
        super(studySessionRepository, studySessionItemRepository, studyAttemptRepository);
        this.mode = mode;
    }

    @Override
    public final StudyMode mode() {
        return this.mode;
    }

    @Override
    public void initializeSession(StudySessionEntity session, List<FlashcardEntity> flashcards) {
        final List<FlashcardEntity> shuffled = shuffleFlashcards(flashcards, session.getSeed());
        final List<StudySessionItemEntity> sessionItems = createSessionItems(session.getId(), shuffled);
        this.studySessionItemRepository.saveAll(sessionItems);
        session.setCurrentIndex(StudyConst.DEFAULT_INDEX);
        session.setTotalUnits(sessionItems.size());
        session.setCorrectCount(StudyConst.ZERO_SCORE);
        session.setWrongCount(StudyConst.ZERO_SCORE);
        this.studySessionRepository.save(session);
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
            StudySessionEventCommand command,
            StudyAttemptEntity attempt) {
        final StudyEventType eventType = command.eventType();
        if (eventType == StudyEventType.REVIEW_NEXT) {
            final int nextIndex = clampIndex(session.getCurrentIndex() + 1, session.getTotalUnits());
            session.setCurrentIndex(nextIndex);
            attempt.setTargetIndex(nextIndex);
            return;
        }
        if (eventType == StudyEventType.REVIEW_PREVIOUS) {
            final int previousIndex = clampIndex(session.getCurrentIndex() - 1, session.getTotalUnits());
            session.setCurrentIndex(previousIndex);
            attempt.setTargetIndex(previousIndex);
            return;
        }
        if (eventType == StudyEventType.REVIEW_GOTO_INDEX) {
            final int targetIndex = resolveTargetIndex(command.targetIndex(), session.getTotalUnits());
            session.setCurrentIndex(targetIndex);
            attempt.setTargetIndex(targetIndex);
            return;
        }
        throw new BadRequestException(StudyConst.EVENT_TYPE_INVALID_KEY);
    }

    @Override
    protected StudySessionResponse buildResponseInternal(StudySessionEntity session) {
        return buildLinearResponse(session);
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

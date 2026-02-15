package com.learn.wire.service.engine;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import org.springframework.stereotype.Component;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.query.StudyEventType;
import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.dto.study.query.StudySessionEventCommand;
import com.learn.wire.dto.study.response.StudyAttemptResultResponse;
import com.learn.wire.dto.study.response.StudyMatchTileResponse;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.MatchSessionStateEntity;
import com.learn.wire.entity.MatchSessionTileEntity;
import com.learn.wire.entity.StudyAttemptEntity;
import com.learn.wire.entity.StudySessionEntity;
import com.learn.wire.entity.StudySessionModeStateEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.MatchSessionStateNotFoundException;
import com.learn.wire.exception.MatchSessionTileNotFoundException;
import com.learn.wire.exception.StudyEventNotSupportedException;
import com.learn.wire.repository.MatchSessionStateRepository;
import com.learn.wire.repository.MatchSessionTileRepository;
import com.learn.wire.repository.StudyAttemptRepository;
import com.learn.wire.repository.StudySessionItemRepository;
import com.learn.wire.repository.StudySessionModeStateRepository;
import com.learn.wire.repository.StudySessionRepository;

@Component
public class MatchStudyModeEngine extends AbstractStudyModeEngine {

    private final MatchSessionTileRepository matchSessionTileRepository;
    private final MatchSessionStateRepository matchSessionStateRepository;

    public MatchStudyModeEngine(
            StudySessionRepository studySessionRepository,
            StudySessionModeStateRepository studySessionModeStateRepository,
            StudySessionItemRepository studySessionItemRepository,
            StudyAttemptRepository studyAttemptRepository,
            MatchSessionTileRepository matchSessionTileRepository,
            MatchSessionStateRepository matchSessionStateRepository) {
        super(
                studySessionRepository,
                studySessionModeStateRepository,
                studySessionItemRepository,
                studyAttemptRepository);
        this.matchSessionTileRepository = matchSessionTileRepository;
        this.matchSessionStateRepository = matchSessionStateRepository;
    }

    @Override
    public StudyMode mode() {
        return StudyMode.MATCH;
    }

    @Override
    public void initializeSession(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState,
            List<FlashcardEntity> flashcards) {
        final var shuffled = shuffleFlashcards(flashcards, session.getSeed());
        if (shuffled.size() >= StudyConst.MINIMUM_MATCH_PAIR_COUNT) {
            final var tiles = createTiles(modeState.getId(), shuffled, session.getSeed());
            this.matchSessionTileRepository.saveAll(tiles);
            final var state = new MatchSessionStateEntity();
            state.setModeStateId(modeState.getId());
            state.setInteractionLocked(false);
            state.setVersion(StudyConst.DEFAULT_INDEX);
            this.matchSessionStateRepository.save(state);
            modeState.setCurrentIndex(StudyConst.DEFAULT_INDEX);
            modeState.setTotalUnits(shuffled.size());
            this.studySessionModeStateRepository.save(modeState);
            return;
        }
        throw new BusinessException(StudyConst.MATCH_REQUIRES_MORE_FLASHCARDS_KEY);
    }

    @Override
    protected void validateSupportedEvent(StudySessionEventCommand command) {
        if (command.eventType().isMatchSelection()) {
            return;
        }
        throw new StudyEventNotSupportedException(mode().value(), command.eventType().value());
    }

    @Override
    protected void handleEventInternal(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState,
            StudySessionEventCommand command,
            StudyAttemptEntity attempt) {
        final var state = getRequiredState(modeState.getId());
        releaseExpiredFeedback(state);
        if (state.isInteractionLocked()) {
            return;
        }
        final var eventType = command.eventType();
        final var expectedSide = resolveExpectedSide(eventType);
        final var tile = resolveTargetTile(modeState.getId(), command.targetTileId(), expectedSide);
        if (tile.isMatched()) {
            return;
        }
        applySelection(state, tile, eventType);
        if (!hasCompleteSelection(state)) {
            this.matchSessionStateRepository.save(state);
            return;
        }
        resolvePairAttempt(modeState, state, attempt);
        this.matchSessionStateRepository.save(state);
    }

    @Override
    protected StudySessionResponse buildResponseInternal(
            StudySessionEntity session,
            StudySessionModeStateEntity modeState) {
        final var state = getRequiredState(modeState.getId());
        releaseExpiredFeedback(state);
        final var leftTiles = this.matchSessionTileRepository
                .findByModeStateIdAndSideOrderByTileOrderAsc(modeState.getId(), StudyConst.TILE_SIDE_LEFT);
        final var rightTiles = this.matchSessionTileRepository
                .findByModeStateIdAndSideOrderByTileOrderAsc(modeState.getId(), StudyConst.TILE_SIDE_RIGHT);
        final var leftResponses = toMatchTileResponses(leftTiles, state);
        final var rightResponses = toMatchTileResponses(rightTiles, state);
        final var lastAttemptResult = toAttemptResult(state);
        return buildSessionResponse(
                session,
                modeState,
                List.of(),
                leftResponses,
                rightResponses,
                lastAttemptResult);
    }

    private List<MatchSessionTileEntity> createTiles(Long modeStateId, List<FlashcardEntity> flashcards, int seed) {
        final List<MatchSessionTileEntity> leftTiles = new ArrayList<>();
        final List<MatchSessionTileEntity> rightTiles = new ArrayList<>();
        var pairKey = StudyConst.DEFAULT_INDEX;
        for (final FlashcardEntity flashcard : flashcards) {
            leftTiles.add(buildTile(modeStateId, pairKey, StudyConst.TILE_SIDE_LEFT, flashcard.getFrontText()));
            rightTiles.add(buildTile(modeStateId, pairKey, StudyConst.TILE_SIDE_RIGHT, flashcard.getBackText()));
            pairKey++;
        }
        Collections.shuffle(leftTiles, new Random(seed + 1L));
        Collections.shuffle(rightTiles, new Random(seed + 2L));
        assignTileOrder(leftTiles);
        assignTileOrder(rightTiles);
        final List<MatchSessionTileEntity> allTiles = new ArrayList<>();
        allTiles.addAll(leftTiles);
        allTiles.addAll(rightTiles);
        return allTiles;
    }

    private MatchSessionTileEntity buildTile(Long modeStateId, int pairKey, String side, String label) {
        final var tile = new MatchSessionTileEntity();
        tile.setModeStateId(modeStateId);
        tile.setPairKey(pairKey);
        tile.setSide(side);
        tile.setLabelText(label);
        tile.setMatched(false);
        return tile;
    }

    private void assignTileOrder(List<MatchSessionTileEntity> tiles) {
        var index = StudyConst.DEFAULT_INDEX;
        for (final MatchSessionTileEntity tile : tiles) {
            tile.setTileOrder(index);
            index++;
        }
    }

    private void applySelection(MatchSessionStateEntity state, MatchSessionTileEntity tile, StudyEventType eventType) {
        if (eventType == StudyEventType.MATCH_SELECT_LEFT) {
            state.setSelectedLeftTileId(tile.getId());
            return;
        }
        state.setSelectedRightTileId(tile.getId());
    }

    private boolean hasCompleteSelection(MatchSessionStateEntity state) {
        if (state.getSelectedLeftTileId() == null) {
            return false;
        }
        return state.getSelectedRightTileId() != null;
    }

    private void resolvePairAttempt(
            StudySessionModeStateEntity modeState,
            MatchSessionStateEntity state,
            StudyAttemptEntity attempt) {
        final var leftTile = resolveTileById(modeState.getId(), state.getSelectedLeftTileId());
        final var rightTile = resolveTileById(modeState.getId(), state.getSelectedRightTileId());
        validateTileSide(leftTile, StudyConst.TILE_SIDE_LEFT);
        validateTileSide(rightTile, StudyConst.TILE_SIDE_RIGHT);
        attempt.setLeftTileId(leftTile.getId());
        attempt.setRightTileId(rightTile.getId());
        if (leftTile.getPairKey() == rightTile.getPairKey()) {
            applySuccessFeedback(modeState, state, leftTile, rightTile, attempt);
            return;
        }
        applyErrorFeedback(modeState, state, leftTile, rightTile, attempt);
    }

    private void applySuccessFeedback(
            StudySessionModeStateEntity modeState,
            MatchSessionStateEntity state,
            MatchSessionTileEntity leftTile,
            MatchSessionTileEntity rightTile,
            StudyAttemptEntity attempt) {
        leftTile.setMatched(true);
        rightTile.setMatched(true);
        this.matchSessionTileRepository.saveAll(List.of(leftTile, rightTile));
        final var nextMatchedCount = modeState.getCurrentIndex() + 1;
        modeState.setCurrentIndex(nextMatchedCount);
        attempt.setIsCorrect(true);
        applyFeedbackState(state, StudyConst.FEEDBACK_SUCCESS, leftTile.getId(), rightTile.getId());
        if (nextMatchedCount < modeState.getTotalUnits()) {
            return;
        }
        modeState.setStatus(StudyConst.SESSION_STATUS_COMPLETED);
        modeState.setCompletedAt(Instant.now());
    }

    private void applyErrorFeedback(
            StudySessionModeStateEntity modeState,
            MatchSessionStateEntity state,
            MatchSessionTileEntity leftTile,
            MatchSessionTileEntity rightTile,
            StudyAttemptEntity attempt) {
        attempt.setIsCorrect(false);
        applyFeedbackState(state, StudyConst.FEEDBACK_ERROR, leftTile.getId(), rightTile.getId());
    }

    private void applyFeedbackState(
            MatchSessionStateEntity state,
            String feedbackStatus,
            Long leftTileId,
            Long rightTileId) {
        state.setSelectedLeftTileId(null);
        state.setSelectedRightTileId(null);
        state.setFeedbackStatus(feedbackStatus);
        state.setFeedbackLeftTileId(leftTileId);
        state.setFeedbackRightTileId(rightTileId);
        state.setFeedbackUntil(Instant.now().plusMillis(StudyConst.MATCH_FEEDBACK_HOLD_MILLIS));
        state.setInteractionLocked(true);
        state.setVersion(state.getVersion() + 1);
    }

    private MatchSessionTileEntity resolveTargetTile(Long modeStateId, Long targetTileId, String expectedSide) {
        if (targetTileId != null) {
            final var tile = resolveTileById(modeStateId, targetTileId);
            validateTileSide(tile, expectedSide);
            return tile;
        }
        throw new BadRequestException(StudyConst.EVENT_TARGET_TILE_REQUIRED_KEY);
    }

    private MatchSessionTileEntity resolveTileById(Long modeStateId, Long tileId) {
        return this.matchSessionTileRepository
                .findByModeStateIdAndId(modeStateId, tileId)
                .orElseThrow(() -> new MatchSessionTileNotFoundException(tileId));
    }

    private MatchSessionStateEntity getRequiredState(Long modeStateId) {
        return this.matchSessionStateRepository
                .findByModeStateId(modeStateId)
                .orElseThrow(() -> new MatchSessionStateNotFoundException(modeStateId));
    }

    private String resolveExpectedSide(StudyEventType eventType) {
        if (eventType == StudyEventType.MATCH_SELECT_LEFT) {
            return StudyConst.TILE_SIDE_LEFT;
        }
        return StudyConst.TILE_SIDE_RIGHT;
    }

    private void validateTileSide(MatchSessionTileEntity tile, String expectedSide) {
        if (expectedSide.equalsIgnoreCase(tile.getSide())) {
            return;
        }
        throw new BusinessException(StudyConst.MATCH_TILE_SIDE_INVALID_KEY, tile.getId(), expectedSide);
    }

    private void releaseExpiredFeedback(MatchSessionStateEntity state) {
        if (!state.isInteractionLocked()) {
            return;
        }
        final var feedbackUntil = state.getFeedbackUntil();
        if (feedbackUntil == null) {
            clearFeedbackState(state);
            this.matchSessionStateRepository.save(state);
            return;
        }
        if (feedbackUntil.isAfter(Instant.now())) {
            return;
        }
        clearFeedbackState(state);
        this.matchSessionStateRepository.save(state);
    }

    private void clearFeedbackState(MatchSessionStateEntity state) {
        state.setInteractionLocked(false);
        state.setFeedbackStatus(null);
        state.setFeedbackLeftTileId(null);
        state.setFeedbackRightTileId(null);
        state.setFeedbackUntil(null);
        state.setVersion(state.getVersion() + 1);
    }

    private List<StudyMatchTileResponse> toMatchTileResponses(
            List<MatchSessionTileEntity> tiles,
            MatchSessionStateEntity state) {
        final List<StudyMatchTileResponse> responses = new ArrayList<>();
        for (final MatchSessionTileEntity tile : tiles) {
            final var successFlash = isSuccessFeedbackTile(state, tile.getId());
            final var errorFlash = isErrorFeedbackTile(state, tile.getId());
            final var hidden = tile.isMatched() && !successFlash;
            final var selected = isSelectedTile(state, tile.getId(), tile.getSide());
            responses.add(new StudyMatchTileResponse(
                    tile.getId(),
                    tile.getPairKey(),
                    tile.getSide(),
                    tile.getLabelText(),
                    tile.getTileOrder(),
                    tile.isMatched(),
                    hidden,
                    selected,
                    successFlash,
                    errorFlash));
        }
        return responses;
    }

    private boolean isSelectedTile(MatchSessionStateEntity state, Long tileId, String side) {
        if (StudyConst.TILE_SIDE_LEFT.equalsIgnoreCase(side)) {
            if (state.getSelectedLeftTileId() == null) {
                return false;
            }
            return state.getSelectedLeftTileId().equals(tileId);
        }
        if (state.getSelectedRightTileId() == null) {
            return false;
        }
        return state.getSelectedRightTileId().equals(tileId);
    }

    private boolean isSuccessFeedbackTile(MatchSessionStateEntity state, Long tileId) {
        if (!StudyConst.FEEDBACK_SUCCESS.equalsIgnoreCase(state.getFeedbackStatus()) || !state.isInteractionLocked()) {
            return false;
        }
        return isFeedbackPairTile(state, tileId);
    }

    private boolean isErrorFeedbackTile(MatchSessionStateEntity state, Long tileId) {
        if (!StudyConst.FEEDBACK_ERROR.equalsIgnoreCase(state.getFeedbackStatus()) || !state.isInteractionLocked()) {
            return false;
        }
        return isFeedbackPairTile(state, tileId);
    }

    private boolean isFeedbackPairTile(MatchSessionStateEntity state, Long tileId) {
        return ((state.getFeedbackLeftTileId() != null) && state.getFeedbackLeftTileId().equals(tileId))
                || ((state.getFeedbackRightTileId() != null) && state.getFeedbackRightTileId().equals(tileId));
    }

    private StudyAttemptResultResponse toAttemptResult(MatchSessionStateEntity state) {
        return new StudyAttemptResultResponse(
                state.getFeedbackStatus(),
                state.getFeedbackLeftTileId(),
                state.getFeedbackRightTileId(),
                state.isInteractionLocked(),
                state.getFeedbackUntil());
    }
}

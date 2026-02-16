package com.learn.wire.study;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.annotation.DirtiesContext;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.response.DeckResponse;
import com.learn.wire.dto.flashcard.request.FlashcardCreateRequest;
import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.response.FolderResponse;
import com.learn.wire.dto.study.request.StudySessionEventRequest;
import com.learn.wire.dto.study.request.StudySessionStartRequest;
import com.learn.wire.dto.study.response.StudyMatchTileResponse;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.service.DeckService;
import com.learn.wire.service.FlashcardService;
import com.learn.wire.service.FolderService;
import com.learn.wire.service.StudySessionService;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
class StudySessionIntegrationTest {

    private static final String DESCRIPTION = "Folder for study tests";
    private static final String COLOR = "#10B981";
    private static final String DISABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY FALSE";
    private static final String ENABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY TRUE";
    private static final String TRUNCATE_MATCH_STATES_SQL = "TRUNCATE TABLE match_session_states";
    private static final String TRUNCATE_MATCH_TILES_SQL = "TRUNCATE TABLE match_session_tiles";
    private static final String TRUNCATE_STUDY_ATTEMPTS_SQL = "TRUNCATE TABLE study_attempts";
    private static final String TRUNCATE_STUDY_ITEMS_SQL = "TRUNCATE TABLE study_session_items";
    private static final String TRUNCATE_STUDY_SNAPSHOT_ITEMS_SQL = "TRUNCATE TABLE study_session_snapshot_items";
    private static final String TRUNCATE_STUDY_MODE_STATES_SQL = "TRUNCATE TABLE study_session_mode_states";
    private static final String TRUNCATE_STUDY_SESSIONS_SQL = "TRUNCATE TABLE study_sessions";
    private static final String TRUNCATE_FLASHCARDS_SQL = "TRUNCATE TABLE flashcards";
    private static final String TRUNCATE_DECKS_SQL = "TRUNCATE TABLE decks";
    private static final String TRUNCATE_FOLDERS_SQL = "TRUNCATE TABLE folders";

    @Autowired
    private FolderService folderService;

    @Autowired
    private DeckService deckService;

    @Autowired
    private FlashcardService flashcardService;

    @Autowired
    private StudySessionService studySessionService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void cleanupData() {
        this.jdbcTemplate.execute(DISABLE_REF_INTEGRITY_SQL);
        this.jdbcTemplate.execute(TRUNCATE_MATCH_STATES_SQL);
        this.jdbcTemplate.execute(TRUNCATE_MATCH_TILES_SQL);
        this.jdbcTemplate.execute(TRUNCATE_STUDY_ATTEMPTS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_STUDY_ITEMS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_STUDY_SNAPSHOT_ITEMS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_STUDY_MODE_STATES_SQL);
        this.jdbcTemplate.execute(TRUNCATE_STUDY_SESSIONS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_FLASHCARDS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_DECKS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_FOLDERS_SQL);
        this.jdbcTemplate.execute(ENABLE_REF_INTEGRITY_SQL);
    }

    @Test
    void startReviewSession_shouldCreateItemsAndDefaultIndex() {
        final Long deckId = createDeckWithFlashcards(_unique("Review"), List.of(
                new FlashcardCreateRequest("apple", "tao"),
                new FlashcardCreateRequest("banana", "chuoi"),
                new FlashcardCreateRequest("cat", "meo")));

        final StudySessionResponse response = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_REVIEW, 11, null));

        assertThat(response.mode()).isEqualTo(StudyConst.MODE_REVIEW);
        assertThat(response.currentIndex()).isEqualTo(StudyConst.DEFAULT_INDEX);
        assertThat(response.totalUnits()).isEqualTo(3);
        assertThat(response.reviewItems()).hasSize(3);
        assertThat(response.leftTiles()).isEmpty();
        assertThat(response.rightTiles()).isEmpty();
        assertThat(response.completedModeCount()).isEqualTo(0);
        assertThat(response.requiredModeCount()).isEqualTo(5);
        assertThat(response.sessionCompleted()).isFalse();
    }

    @Test
    void matchMode_wrongSelection_shouldFlashOnlyWrongPair() {
        final Long deckId = createDeckWithFlashcards(_unique("Match"), List.of(
                new FlashcardCreateRequest("red", "do"),
                new FlashcardCreateRequest("blue", "xanh"),
                new FlashcardCreateRequest("green", "la")));

        final StudySessionResponse started = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_MATCH, 13, null));
        final StudyMatchTileResponse leftTile = started.leftTiles().get(0);
        final StudyMatchTileResponse wrongRightTile = findWrongRightTile(started.rightTiles(), leftTile.pairKey());

        this.studySessionService.submitEvent(
                started.sessionId(),
                new StudySessionEventRequest(
                        "evt-left",
                        0,
                        StudyConst.EVENT_MATCH_SELECT_LEFT,
                        leftTile.tileId(),
                        null));

        final StudySessionResponse wrongAttempt = this.studySessionService.submitEvent(
                started.sessionId(),
                new StudySessionEventRequest(
                        "evt-right",
                        1,
                        StudyConst.EVENT_MATCH_SELECT_RIGHT,
                        wrongRightTile.tileId(),
                        null));

        assertThat(wrongAttempt.lastAttemptResult()).isNotNull();
        assertThat(wrongAttempt.lastAttemptResult().feedbackStatus()).isEqualTo(StudyConst.FEEDBACK_ERROR);
        assertThat(wrongAttempt.lastAttemptResult().interactionLocked()).isTrue();

        final long leftErrorCount = wrongAttempt.leftTiles().stream().filter(StudyMatchTileResponse::errorFlash).count();
        final long rightErrorCount = wrongAttempt.rightTiles().stream().filter(StudyMatchTileResponse::errorFlash).count();
        assertThat(leftErrorCount).isEqualTo(1);
        assertThat(rightErrorCount).isEqualTo(1);

        final StudyMatchTileResponse errorLeftTile = wrongAttempt.leftTiles().stream()
                .filter(StudyMatchTileResponse::errorFlash)
                .findFirst()
                .orElseThrow();
        final StudyMatchTileResponse errorRightTile = wrongAttempt.rightTiles().stream()
                .filter(StudyMatchTileResponse::errorFlash)
                .findFirst()
                .orElseThrow();
        assertThat(errorLeftTile.tileId()).isEqualTo(leftTile.tileId());
        assertThat(errorRightTile.tileId()).isEqualTo(wrongRightTile.tileId());
    }

    @Test
    void submitEvent_withDuplicateClientSequence_shouldReturnCurrentStateWithoutError() {
        final Long deckId = createDeckWithFlashcards(_unique("DuplicateSequence"), List.of(
                new FlashcardCreateRequest("one", "mot"),
                new FlashcardCreateRequest("two", "hai"),
                new FlashcardCreateRequest("three", "ba")));

        final StudySessionResponse started = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_REVIEW, 41, null));

        final StudySessionResponse firstNext = this.studySessionService.submitEvent(
                started.sessionId(),
                new StudySessionEventRequest(
                        "evt-dup-seq-1",
                        1,
                        StudyConst.EVENT_REVIEW_NEXT,
                        null,
                        1));

        final StudySessionResponse duplicateSequenceEvent = this.studySessionService.submitEvent(
                started.sessionId(),
                new StudySessionEventRequest(
                        "evt-dup-seq-2",
                        1,
                        StudyConst.EVENT_REVIEW_NEXT,
                        null,
                        2));

        assertThat(firstNext.currentIndex()).isEqualTo(1);
        assertThat(duplicateSequenceEvent.currentIndex()).isEqualTo(1);
    }

    @Test
    void completeAllModes_shouldCompleteSingleCycleSession() {
        final Long deckId = createDeckWithFlashcards(_unique("Cycle"), List.of(
                new FlashcardCreateRequest("alpha", "mot"),
                new FlashcardCreateRequest("beta", "hai"),
                new FlashcardCreateRequest("gamma", "ba")));

        final StudySessionResponse reviewSession = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_REVIEW, 17, null));
        final StudySessionResponse completedReview = this.studySessionService.completeSession(reviewSession.sessionId());
        assertThat(completedReview.completed()).isTrue();
        assertThat(completedReview.sessionCompleted()).isFalse();

        final StudySessionResponse guessSession = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_GUESS, 19, null));
        assertThat(guessSession.sessionId()).isEqualTo(reviewSession.sessionId());
        final StudySessionResponse completedGuess = this.studySessionService.completeSession(guessSession.sessionId());
        assertThat(completedGuess.sessionCompleted()).isFalse();

        final StudySessionResponse recallSession = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_RECALL, 23, null));
        assertThat(recallSession.sessionId()).isEqualTo(reviewSession.sessionId());
        final StudySessionResponse completedRecall = this.studySessionService.completeSession(recallSession.sessionId());
        assertThat(completedRecall.sessionCompleted()).isFalse();

        final StudySessionResponse fillSession = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_FILL, 29, null));
        assertThat(fillSession.sessionId()).isEqualTo(reviewSession.sessionId());
        final StudySessionResponse completedFill = this.studySessionService.completeSession(fillSession.sessionId());
        assertThat(completedFill.sessionCompleted()).isFalse();

        final StudySessionResponse matchSession = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_MATCH, 31, null));
        assertThat(matchSession.sessionId()).isEqualTo(reviewSession.sessionId());
        final StudySessionResponse completedMatch = this.studySessionService.completeSession(matchSession.sessionId());

        assertThat(completedMatch.completedModeCount()).isEqualTo(5);
        assertThat(completedMatch.requiredModeCount()).isEqualTo(5);
        assertThat(completedMatch.sessionCompleted()).isTrue();
        assertThat(completedMatch.status()).isEqualTo(StudyConst.SESSION_STATUS_COMPLETED);
    }

    @Test
    void restartFromCompletedMode_shouldResumeAtNextIncompleteMode() {
        final Long deckId = createDeckWithFlashcards(_unique("ResumeCycle"), List.of(
                new FlashcardCreateRequest("sun", "mat troi"),
                new FlashcardCreateRequest("moon", "mat trang"),
                new FlashcardCreateRequest("star", "ngoi sao")));

        final StudySessionResponse startedMatch = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_MATCH, 77, null));
        final StudySessionResponse completedMatch = this.studySessionService.completeSession(startedMatch.sessionId());
        assertThat(completedMatch.mode()).isEqualTo(StudyConst.MODE_MATCH);
        assertThat(completedMatch.completed()).isTrue();

        final StudySessionResponse resumed = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_MATCH, 79, null));

        assertThat(resumed.sessionId()).isEqualTo(startedMatch.sessionId());
        assertThat(resumed.mode()).isEqualTo(StudyConst.MODE_GUESS);
        assertThat(resumed.completed()).isFalse();
        assertThat(resumed.totalUnits()).isEqualTo(3);
    }

    @Test
    void sessionSnapshot_shouldKeepSameFlashcardSetAcrossModesWhenDeckChanges() {
        final Long deckId = createDeckWithFlashcards(_unique("Snapshot"), List.of(
                new FlashcardCreateRequest("car", "xe hoi"),
                new FlashcardCreateRequest("bike", "xe dap"),
                new FlashcardCreateRequest("bus", "xe buyt")));

        final StudySessionResponse reviewSession = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_REVIEW, 83, null));

        this.flashcardService.createFlashcard(deckId, new FlashcardCreateRequest("train", "tau hoa"));

        final StudySessionResponse guessSession = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_GUESS, 89, null));

        assertThat(guessSession.sessionId()).isEqualTo(reviewSession.sessionId());
        assertThat(guessSession.totalUnits()).isEqualTo(reviewSession.totalUnits());
        assertThat(guessSession.totalUnits()).isEqualTo(3);
        assertThat(guessSession.reviewItems())
                .extracting(item -> item.flashcardId())
                .containsExactlyElementsOf(
                        reviewSession.reviewItems().stream().map(item -> item.flashcardId()).toList());
    }

    private StudyMatchTileResponse findWrongRightTile(List<StudyMatchTileResponse> rightTiles, int pairKey) {
        for (final StudyMatchTileResponse candidate : rightTiles) {
            if (candidate.pairKey() != pairKey) {
                return candidate;
            }
        }
        throw new IllegalStateException("No wrong pair found for test data.");
    }

    private Long createDeckWithFlashcards(String folderName, List<FlashcardCreateRequest> flashcards) {
        final FolderResponse folder = this.folderService.createFolder(
                new FolderCreateRequest(folderName, DESCRIPTION, COLOR, null));
        final DeckResponse deck = this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest(_unique("Deck"), "Study deck"));
        for (final FlashcardCreateRequest request : flashcards) {
            this.flashcardService.createFlashcard(deck.id(), request);
        }
        return deck.id();
    }

    private String _unique(String prefix) {
        return prefix + "-" + System.nanoTime();
    }
}

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
                new StudySessionStartRequest(StudyConst.MODE_REVIEW, 11));

        assertThat(response.mode()).isEqualTo(StudyConst.MODE_REVIEW);
        assertThat(response.currentIndex()).isEqualTo(StudyConst.DEFAULT_INDEX);
        assertThat(response.totalUnits()).isEqualTo(3);
        assertThat(response.reviewItems()).hasSize(3);
        assertThat(response.leftTiles()).isEmpty();
        assertThat(response.rightTiles()).isEmpty();
    }

    @Test
    void matchMode_wrongSelection_shouldFlashOnlyWrongPair() {
        final Long deckId = createDeckWithFlashcards(_unique("Match"), List.of(
                new FlashcardCreateRequest("red", "do"),
                new FlashcardCreateRequest("blue", "xanh"),
                new FlashcardCreateRequest("green", "la")));

        final StudySessionResponse started = this.studySessionService.startSession(
                deckId,
                new StudySessionStartRequest(StudyConst.MODE_MATCH, 13));
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

        assertThat(wrongAttempt.wrongCount()).isEqualTo(1);
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

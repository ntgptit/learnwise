package com.learn.wire.flashcard;

import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.annotation.DirtiesContext;

import com.learn.wire.constant.FolderConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.response.DeckResponse;
import com.learn.wire.dto.flashcard.query.FlashcardListQuery;
import com.learn.wire.dto.flashcard.request.FlashcardCreateRequest;
import com.learn.wire.dto.flashcard.request.FlashcardListRequest;
import com.learn.wire.dto.flashcard.request.FlashcardUpdateRequest;
import com.learn.wire.dto.flashcard.response.FlashcardResponse;
import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.response.FolderResponse;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.service.DeckService;
import com.learn.wire.service.FlashcardService;
import com.learn.wire.service.FolderService;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
class FlashcardCrudIntegrationTest {

    private static final String DESCRIPTION = "Folder for flashcard tests";
    private static final String COLOR = "#10B981";
    private static final String DISABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY FALSE";
    private static final String ENABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY TRUE";
    private static final String TRUNCATE_FLASHCARDS_SQL = "TRUNCATE TABLE flashcards";
    private static final String TRUNCATE_DECKS_SQL = "TRUNCATE TABLE decks";
    private static final String TRUNCATE_FOLDERS_SQL = "TRUNCATE TABLE folders";

    @Autowired
    private FolderService folderService;

    @Autowired
    private FlashcardService flashcardService;

    @Autowired
    private DeckService deckService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void cleanupData() {
        this.jdbcTemplate.execute(DISABLE_REF_INTEGRITY_SQL);
        this.jdbcTemplate.execute(TRUNCATE_FLASHCARDS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_DECKS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_FOLDERS_SQL);
        this.jdbcTemplate.execute(ENABLE_REF_INTEGRITY_SQL);
    }

    @Test
    void createAndListFlashcards_shouldPersistByDeck() {
        final FolderResponse folder = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Flashcard Root"), DESCRIPTION, COLOR, null));
        final DeckResponse deck = this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest(_unique("Default Deck"), "Default deck"));
        final FlashcardResponse createdFirst = this.flashcardService.createFlashcard(
                deck.id(),
                new FlashcardCreateRequest("  front one  ", "  back one  "));
        final FlashcardResponse createdSecond = this.flashcardService.createFlashcard(
                deck.id(),
                new FlashcardCreateRequest("front two", "back two"));

        final FlashcardListRequest request = new FlashcardListRequest();
        final FlashcardListQuery query = FlashcardListQuery.fromRequest(deck.id(), request);
        final PageResponse<FlashcardResponse> page = this.flashcardService.getFlashcards(query);

        assertThat(page.items()).hasSizeGreaterThanOrEqualTo(2);
        assertThat(page.items().stream().map(FlashcardResponse::id))
                .contains(createdFirst.id(), createdSecond.id());
        assertThat(createdFirst.frontText()).isEqualTo("front one");
        assertThat(createdFirst.backText()).isEqualTo("back one");
    }

    @Test
    void createDeck_shouldRejectWhenFolderHasSubfolders() {
        final FolderResponse parent = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Parent"), DESCRIPTION, COLOR, null));
        this.folderService.createFolder(
                new FolderCreateRequest(_unique("Child"), DESCRIPTION, COLOR, parent.id()));

        assertThatThrownBy(() -> this.deckService.createDeck(
                parent.id(),
                new DeckCreateRequest(_unique("Deck"), "Deck blocked")))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    void createFolder_shouldRejectWhenFolderHasDecks() {
        final FolderResponse folder = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Leaf"), DESCRIPTION, COLOR, null));
        this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest(_unique("Deck"), "Created first deck"));

        assertThatThrownBy(() -> this.folderService.createFolder(
                new FolderCreateRequest(_unique("Nested"), DESCRIPTION, COLOR, folder.id())))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    void updateAndDeleteFlashcard_shouldKeepFolderCountsConsistent() {
        final FolderResponse folder = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Count Root"), DESCRIPTION, COLOR, null));
        final DeckResponse deck = this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest(_unique("Count Deck"), "Count deck"));
        final FlashcardResponse created = this.flashcardService.createFlashcard(
                deck.id(),
                new FlashcardCreateRequest("front initial", "back initial"));

        final FlashcardResponse updated = this.flashcardService.updateFlashcard(
                deck.id(),
                created.id(),
                new FlashcardUpdateRequest("front updated", "back updated"));
        assertThat(updated.frontText()).isEqualTo("front updated");
        assertThat(updated.backText()).isEqualTo("back updated");

        final FolderResponse afterCreate = this.folderService.getFolder(folder.id());
        assertThat(afterCreate.directFlashcardCount()).isEqualTo(1);
        assertThat(afterCreate.flashcardCount()).isEqualTo(1);

        this.flashcardService.deleteFlashcard(deck.id(), created.id());

        final FolderResponse afterDelete = this.folderService.getFolder(folder.id());
        assertThat(afterDelete.directFlashcardCount()).isEqualTo(FolderConst.MIN_PAGE);
        assertThat(afterDelete.flashcardCount()).isEqualTo(FolderConst.MIN_PAGE);
        final FlashcardListRequest request = new FlashcardListRequest();
        final FlashcardListQuery query = FlashcardListQuery.fromRequest(deck.id(), request);
        final PageResponse<FlashcardResponse> page = this.flashcardService.getFlashcards(query);
        final List<Long> ids = page.items().stream().map(FlashcardResponse::id).toList();
        assertThat(ids).doesNotContain(created.id());
    }

    private String _unique(String prefix) {
        return prefix + "-" + System.nanoTime();
    }
}

package com.learn.wire.deck;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.annotation.DirtiesContext;

import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.request.DeckUpdateRequest;
import com.learn.wire.dto.deck.response.DeckResponse;
import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.response.FolderResponse;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.service.DeckService;
import com.learn.wire.service.FolderService;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_CLASS)
class DeckCrudIntegrationTest {

    private static final String DESCRIPTION = "Folder for deck tests";
    private static final String COLOR = "#10B981";
    private static final String DISABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY FALSE";
    private static final String ENABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY TRUE";
    private static final String TRUNCATE_FLASHCARDS_SQL = "TRUNCATE TABLE flashcards";
    private static final String TRUNCATE_DECKS_SQL = "TRUNCATE TABLE decks";
    private static final String TRUNCATE_FOLDERS_SQL = "TRUNCATE TABLE folders";

    @Autowired
    private DeckService deckService;

    @Autowired
    private FolderService folderService;

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
    void createDeck_shouldRejectDuplicateNameInSameFolder() {
        final FolderResponse folder = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Root"), DESCRIPTION, COLOR, null));
        this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest("Vocabulary", "Primary deck"));

        assertThatThrownBy(() -> this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest("  vocabulary  ", "Duplicate deck")))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    void createDeck_shouldAllowSameNameInDifferentFolders() {
        final FolderResponse firstFolder = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Root-A"), DESCRIPTION, COLOR, null));
        final FolderResponse secondFolder = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Root-B"), DESCRIPTION, COLOR, null));

        final DeckResponse firstDeck = this.deckService.createDeck(
                firstFolder.id(),
                new DeckCreateRequest("Shared Name", "Deck in first folder"));
        final DeckResponse secondDeck = this.deckService.createDeck(
                secondFolder.id(),
                new DeckCreateRequest("shared name", "Deck in second folder"));

        assertThat(firstDeck.id()).isNotEqualTo(secondDeck.id());
    }

    @Test
    void updateDeck_shouldRejectDuplicateNameInSameFolder() {
        final FolderResponse folder = this.folderService.createFolder(
                new FolderCreateRequest(_unique("Root"), DESCRIPTION, COLOR, null));
        final DeckResponse firstDeck = this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest("Deck One", "First"));
        final DeckResponse secondDeck = this.deckService.createDeck(
                folder.id(),
                new DeckCreateRequest("Deck Two", "Second"));

        assertThatThrownBy(() -> this.deckService.updateDeck(
                folder.id(),
                secondDeck.id(),
                new DeckUpdateRequest(" deck one ", "Updated")))
                .isInstanceOf(BusinessException.class);

        assertThat(firstDeck.name()).isEqualTo("Deck One");
    }

    private String _unique(String prefix) {
        return prefix + "-" + System.nanoTime();
    }
}

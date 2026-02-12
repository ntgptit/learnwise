package com.learn.wire.folder;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;

import com.learn.wire.constant.FolderConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.folder.query.FolderListQuery;
import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.request.FolderListRequest;
import com.learn.wire.dto.folder.request.FolderUpdateRequest;
import com.learn.wire.dto.folder.response.FolderResponse;
import com.learn.wire.entity.FolderEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.FolderNotFoundException;
import com.learn.wire.repository.FolderRepository;
import com.learn.wire.service.DeckService;
import com.learn.wire.service.FolderService;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.data.domain.Sort.Direction.ASC;
import static org.springframework.data.domain.Sort.Direction.DESC;

@SpringBootTest
@TestMethodOrder(OrderAnnotation.class)
class FolderCrudIntegrationTest {

    private static final String ROOT_ALPHA_NAME = "Alpha Root";
    private static final String ROOT_BETA_NAME = "Beta Root";
    private static final String ROOT_GAMMA_NAME = "Gamma Root";
    private static final String CHILD_NAME = "Alpha Child";
    private static final String DESCRIPTION = "Folder for flashcard grouping";
    private static final String COLOR_ALPHA = "#10B981";
    private static final String COLOR_BETA = "#2563EB";
    private static final String COLOR_GAMMA = "#F59E0B";
    private static final String UPDATED_NAME = "Alpha Root Updated";
    private static final String DISABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY FALSE";
    private static final String ENABLE_REF_INTEGRITY_SQL = "SET REFERENTIAL_INTEGRITY TRUE";
    private static final String TRUNCATE_FLASHCARDS_SQL = "TRUNCATE TABLE flashcards";
    private static final String TRUNCATE_DECKS_SQL = "TRUNCATE TABLE decks";
    private static final String TRUNCATE_FOLDERS_SQL = "TRUNCATE TABLE folders";

    private static Long rootAlphaId;
    private static Long rootBetaId;
    private static Long rootGammaId;
    private static Long alphaChildId;

    @Autowired
    private FolderService folderService;

    @Autowired
    private FolderRepository folderRepository;

    @Autowired
    private DeckService deckService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    @Order(1)
    void createFolders_shouldPersistHierarchyAndAuditFields() {
        this.jdbcTemplate.execute(DISABLE_REF_INTEGRITY_SQL);
        this.jdbcTemplate.execute(TRUNCATE_FLASHCARDS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_DECKS_SQL);
        this.jdbcTemplate.execute(TRUNCATE_FOLDERS_SQL);
        this.jdbcTemplate.execute(ENABLE_REF_INTEGRITY_SQL);

        final FolderResponse rootAlpha = this.folderService.createFolder(
                new FolderCreateRequest(ROOT_ALPHA_NAME, DESCRIPTION, COLOR_ALPHA, null));
        final FolderResponse rootBeta = this.folderService.createFolder(
                new FolderCreateRequest(ROOT_BETA_NAME, DESCRIPTION, COLOR_BETA, null));
        final FolderResponse rootGamma = this.folderService.createFolder(
                new FolderCreateRequest(ROOT_GAMMA_NAME, DESCRIPTION, COLOR_GAMMA, null));
        final FolderResponse alphaChild = this.folderService.createFolder(
                new FolderCreateRequest(CHILD_NAME, DESCRIPTION, COLOR_ALPHA, rootAlpha.id()));

        rootAlphaId = rootAlpha.id();
        rootBetaId = rootBeta.id();
        rootGammaId = rootGamma.id();
        alphaChildId = alphaChild.id();

        assertThat(rootAlpha.createdBy()).isEqualTo(FolderConst.DEFAULT_ACTOR);
        assertThat(rootAlpha.updatedBy()).isEqualTo(FolderConst.DEFAULT_ACTOR);
        assertThat(rootAlpha.parentFolderId()).isNull();
        assertThat(alphaChild.parentFolderId()).isEqualTo(rootAlpha.id());
    }

    @Test
    @Order(2)
    void createFolder_shouldRejectDuplicateNameInSameParent() {
        assertThatThrownBy(() -> this.folderService.createFolder(
                new FolderCreateRequest(ROOT_ALPHA_NAME, DESCRIPTION, COLOR_ALPHA, null)))
                .isInstanceOf(BusinessException.class);

        assertThatThrownBy(() -> this.folderService.createFolder(
                new FolderCreateRequest(CHILD_NAME, DESCRIPTION, COLOR_ALPHA, rootAlphaId)))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    @Order(3)
    void getFolders_shouldReturnRootLevelWhenParentFolderIdIsNull() {
        final PageResponse<FolderResponse> rootPage = this.folderService.getFolders(
                _toFolderListQuery(
                        null,
                        FolderConst.SORT_BY_CREATED_AT,
                        FolderConst.SORT_DIRECTION_ASC));

        assertThat(rootPage.items()).hasSize(3);
        assertThat(rootPage.items().stream().map(FolderResponse::id))
                .contains(rootAlphaId, rootBetaId, rootGammaId)
                .doesNotContain(alphaChildId);
    }

    @Test
    @Order(4)
    void getFolders_shouldReturnDirectChildrenByParentFolderId() {
        final PageResponse<FolderResponse> childPage = this.folderService.getFolders(
                _toFolderListQuery(
                        rootAlphaId,
                        FolderConst.SORT_BY_CREATED_AT,
                        FolderConst.SORT_DIRECTION_ASC));

        assertThat(childPage.items()).hasSize(1);
        assertThat(childPage.items().get(0).id()).isEqualTo(alphaChildId);
        assertThat(childPage.items().get(0).parentFolderId()).isEqualTo(rootAlphaId);
    }

    @Test
    @Order(5)
    void getFolders_shouldSupportSortByNameAndCreatedAt() {
        final PageResponse<FolderResponse> sortedByName = this.folderService.getFolders(
                _toFolderListQuery(
                        null,
                        FolderConst.SORT_BY_NAME,
                        FolderConst.SORT_DIRECTION_ASC));

        assertThat(sortedByName.items().get(0).name()).isEqualTo(ROOT_ALPHA_NAME);
        assertThat(sortedByName.sortDirection()).isEqualTo(ASC.name().toLowerCase());

        final PageResponse<FolderResponse> sortedByCreatedAt = this.folderService.getFolders(
                _toFolderListQuery(
                        null,
                        FolderConst.SORT_BY_CREATED_AT,
                        FolderConst.SORT_DIRECTION_DESC));

        assertThat(sortedByCreatedAt.items().get(0).name()).isEqualTo(ROOT_GAMMA_NAME);
        assertThat(sortedByCreatedAt.sortDirection()).isEqualTo(DESC.name().toLowerCase());
    }

    @Test
    @Order(6)
    void getFolders_shouldSortByFlashcardCountIncludingSubfolders() {
        _setDirectFlashcardCount(rootAlphaId, 2);
        _setDirectFlashcardCount(rootBetaId, 4);
        _setDirectFlashcardCount(rootGammaId, 1);
        _setDirectFlashcardCount(alphaChildId, 3);

        final PageResponse<FolderResponse> sortedByFlashcardCount = this.folderService.getFolders(
                _toFolderListQuery(
                        null,
                        FolderConst.SORT_BY_FLASHCARD_COUNT,
                        FolderConst.SORT_DIRECTION_DESC));

        assertThat(sortedByFlashcardCount.items().get(0).id()).isEqualTo(rootAlphaId);
        assertThat(sortedByFlashcardCount.items().get(0).flashcardCount()).isEqualTo(5);
        assertThat(sortedByFlashcardCount.items().get(1).id()).isEqualTo(rootBetaId);
        assertThat(sortedByFlashcardCount.items().get(1).flashcardCount()).isEqualTo(4);
    }

    @Test
    @Order(7)
    void createFolder_shouldRejectWhenParentHasDirectDecks() {
        this.deckService.createDeck(
                rootBetaId,
                new DeckCreateRequest("Beta Deck", "Deck to block nested folders"));
        assertThatThrownBy(() -> this.folderService.createFolder(
                new FolderCreateRequest("Nested under Beta", DESCRIPTION, COLOR_ALPHA, rootBetaId)))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    @Order(8)
    void updateFolder_shouldRejectMoveToParentWithDirectDecks() {
        assertThatThrownBy(() -> this.folderService.updateFolder(
                rootGammaId,
                new FolderUpdateRequest(ROOT_GAMMA_NAME, DESCRIPTION, COLOR_GAMMA, rootBetaId)))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    @Order(9)
    void updateFolder_shouldValidateParentCycleAndApplyChanges() {
        final FolderUpdateRequest invalidParentRequest =
                new FolderUpdateRequest(UPDATED_NAME, DESCRIPTION, COLOR_ALPHA, alphaChildId);
        assertThatThrownBy(() -> this.folderService.updateFolder(
                rootAlphaId,
                invalidParentRequest))
                .isInstanceOf(BadRequestException.class);

        assertThatThrownBy(() -> this.folderService.updateFolder(
                rootGammaId,
                new FolderUpdateRequest(ROOT_BETA_NAME, DESCRIPTION, COLOR_GAMMA, null)))
                .isInstanceOf(BusinessException.class);

        final FolderResponse updated = this.folderService.updateFolder(
                rootAlphaId,
                new FolderUpdateRequest(UPDATED_NAME, DESCRIPTION, COLOR_ALPHA, null));

        assertThat(updated.name()).isEqualTo(UPDATED_NAME);
        assertThat(updated.parentFolderId()).isNull();
    }

    @Test
    @Order(10)
    void deleteFolder_shouldSoftDeleteSubtree() {
        this.folderService.deleteFolder(rootAlphaId);

        assertThatThrownBy(() -> this.folderService.getFolder(rootAlphaId))
                .isInstanceOf(FolderNotFoundException.class);
        assertThatThrownBy(() -> this.folderService.getFolder(alphaChildId))
                .isInstanceOf(FolderNotFoundException.class);

        final PageResponse<FolderResponse> rootPage = this.folderService.getFolders(
                _toFolderListQuery(
                        null,
                        FolderConst.SORT_BY_NAME,
                        FolderConst.SORT_DIRECTION_ASC));
        final List<Long> rootIds = rootPage.items().stream().map(FolderResponse::id).toList();
        assertThat(rootIds)
                .contains(rootBetaId, rootGammaId)
                .doesNotContain(rootAlphaId);
    }

    private FolderListQuery _toFolderListQuery(Long parentFolderId, String sortBy, String sortDirection) {
        final FolderListRequest request = new FolderListRequest();
        request.setParentFolderId(parentFolderId);
        request.setSortBy(sortBy);
        request.setSortDirection(sortDirection);
        return FolderListQuery.fromRequest(request);
    }

    private void _setDirectFlashcardCount(Long folderId, int count) {
        final FolderEntity entity = this.folderRepository.findById(folderId).orElseThrow();
        entity.setDirectFlashcardCount(count);
        this.folderRepository.save(entity);
        _recalculateAggregateFlashcardCounts();
    }

    private void _recalculateAggregateFlashcardCounts() {
        final List<FolderEntity> activeFolders = this.folderRepository.findByDeletedAtIsNull();
        final Map<Long, FolderEntity> folderById = new HashMap<>();
        final Map<Long, List<FolderEntity>> childrenByParent = new HashMap<>();

        for (final FolderEntity folder : activeFolders) {
            folderById.put(folder.getId(), folder);
            final List<FolderEntity> children = childrenByParent.computeIfAbsent(
                    folder.getParentFolderId(),
                    ignored -> new ArrayList<>());
            children.add(folder);
        }

        final Map<Long, Integer> cache = new HashMap<>();
        for (final FolderEntity folder : activeFolders) {
            final int aggregate = _resolveAggregate(
                    folder.getId(),
                    folderById,
                    childrenByParent,
                    cache);
            folder.setAggregateFlashcardCount(aggregate);
        }
        this.folderRepository.saveAll(activeFolders);
    }

    private int _resolveAggregate(
            Long folderId,
            Map<Long, FolderEntity> folderById,
            Map<Long, List<FolderEntity>> childrenByParent,
            Map<Long, Integer> cache) {
        final Integer cached = cache.get(folderId);
        if (cached != null) {
            return cached;
        }

        final FolderEntity folder = folderById.get(folderId);
        if (folder == null) {
            return 0;
        }

        int total = folder.getDirectFlashcardCount();
        final List<FolderEntity> children = childrenByParent.get(folderId);
        if (children != null) {
            for (final FolderEntity child : children) {
                total += _resolveAggregate(child.getId(), folderById, childrenByParent, cache);
            }
        }
        cache.put(folderId, total);
        return total;
    }
}

package com.learn.wire.service.impl;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.constant.DeckConst;
import com.learn.wire.constant.FolderConst;
import com.learn.wire.constant.LogConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.deck.query.DeckListQuery;
import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.request.DeckUpdateRequest;
import com.learn.wire.dto.deck.response.DeckResponse;
import com.learn.wire.entity.AppUserEntity;
import com.learn.wire.entity.DeckEntity;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.FolderEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.DeckNotFoundException;
import com.learn.wire.exception.FolderNotFoundException;
import com.learn.wire.mapper.DeckMapper;
import com.learn.wire.repository.AppUserRepository;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.FlashcardRepository.DeckFlashcardCountProjection;
import com.learn.wire.repository.FolderRepository;
import com.learn.wire.security.CurrentUserAccessor;
import com.learn.wire.service.DeckService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class DeckServiceImpl implements DeckService {

    private final DeckRepository deckRepository;
    private final AppUserRepository appUserRepository;
    private final FolderRepository folderRepository;
    private final FlashcardRepository flashcardRepository;
    private final DeckMapper deckMapper;
    private final CurrentUserAccessor currentUserAccessor;

    @Override
    @Transactional(readOnly = true)
    public PageResponse<DeckResponse> getDecks(DeckListQuery query) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        log.debug(
                LogConst.DECK_SERVICE_GET_LIST,
                query.folderId(),
                query.page(),
                query.size(),
                query.sortField().value(),
                query.sortDirection().value());
        getActiveFolderEntity(query.folderId(), currentActor);
        final var sort = Sort.by(query.sortDirection().toSpringDirection(), query.sortField().sortProperty());
        final Pageable pageable = PageRequest.of(query.page(), query.size(), sort);
        final var page = this.deckRepository.findPageByFolderAndSearch(
                query.folderId(),
                currentActor,
                query.search(),
                pageable);
        final var flashcardCountByDeck = resolveFlashcardCountByDeck(page.getContent(), currentActor);
        final var actorDisplayNameByActor = resolveActorDisplayNameByActor(page.getContent());
        final var items = toResponses(page.getContent(), flashcardCountByDeck, actorDisplayNameByActor);
        return new PageResponse<>(
                items,
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.hasNext(),
                page.hasPrevious(),
                query.search(),
                query.sortField().value(),
                query.sortDirection().value());
    }

    @Override
    @Transactional(readOnly = true)
    public DeckResponse getDeck(Long folderId, Long deckId) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        final var deck = getActiveDeckEntity(folderId, deckId, currentActor);
        final var flashcardCount = this.flashcardRepository.countByDeckIdAndCreatedByAndDeletedAtIsNull(
                deckId,
                currentActor);
        final var actorDisplayNameByActor = resolveActorDisplayNameByActor(List.of(deck));
        return toResponse(deck, flashcardCount, actorDisplayNameByActor);
    }

    @Override
    public DeckResponse createDeck(Long folderId, DeckCreateRequest request) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        log.info(LogConst.DECK_SERVICE_CREATE, folderId);
        getActiveFolderEntity(folderId, currentActor);
        validateRequest(request.name(), request.description());
        validateFolderAllowsDeckCreation(folderId, currentActor);
        final var normalizedName = normalizeName(request.name());
        final var normalizedNameForIndex = normalizeNameForIndex(normalizedName);
        validateNameUniquenessForCreate(folderId, normalizedNameForIndex, currentActor);

        final var entity = this.deckMapper.toEntity(request);
        entity.setFolderId(folderId);
        entity.setName(normalizedName);
        entity.setNormalizedName(normalizedNameForIndex);
        entity.setDescription(normalizeDescription(request.description()));
        entity.setCreatedBy(currentActor);
        entity.setUpdatedBy(currentActor);

        final var created = persistDeckWithDuplicateNameGuard(entity);
        final var actorDisplayNameByActor = resolveActorDisplayNameByActor(List.of(created));
        return toResponse(created, 0L, actorDisplayNameByActor);
    }

    @Override
    public DeckResponse updateDeck(Long folderId, Long deckId, DeckUpdateRequest request) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        log.info(LogConst.DECK_SERVICE_UPDATE, deckId, folderId);
        validateRequest(request.name(), request.description());
        final var normalizedName = normalizeName(request.name());
        final var normalizedNameForIndex = normalizeNameForIndex(normalizedName);
        final var deck = getActiveDeckEntity(folderId, deckId, currentActor);
        validateNameUniquenessForUpdate(folderId, deckId, normalizedNameForIndex, currentActor);
        this.deckMapper.updateEntity(request, deck);
        deck.setName(normalizedName);
        deck.setNormalizedName(normalizedNameForIndex);
        deck.setDescription(normalizeDescription(request.description()));
        deck.setUpdatedBy(currentActor);
        final var updated = persistDeckWithDuplicateNameGuard(deck);
        final var flashcardCount = this.flashcardRepository.countByDeckIdAndCreatedByAndDeletedAtIsNull(
                deckId,
                currentActor);
        final var actorDisplayNameByActor = resolveActorDisplayNameByActor(List.of(updated));
        return toResponse(updated, flashcardCount, actorDisplayNameByActor);
    }

    @Override
    public void deleteDeck(Long folderId, Long deckId) {
        final var currentActor = this.currentUserAccessor.getCurrentActor();
        log.info(LogConst.DECK_SERVICE_DELETE, deckId, folderId);
        final var deck = getActiveDeckEntity(folderId, deckId, currentActor);
        final var activeFlashcards = this.flashcardRepository
                .findByDeckIdAndCreatedByAndDeletedAtIsNull(
                        deckId,
                        currentActor);
        if (!activeFlashcards.isEmpty()) {
            final var activeFolders = this.folderRepository.findByCreatedByAndDeletedAtIsNull(
                    currentActor);
            final var folderById = toFolderById(activeFolders);
            applyFlashcardDelta(deck.getFolderId(), -activeFlashcards.size(), folderById, currentActor);
            this.folderRepository.saveAll(activeFolders);

            final var deletedAt = Instant.now();
            for (final FlashcardEntity flashcard : activeFlashcards) {
                flashcard.setDeletedAt(deletedAt);
                flashcard.setDeletedBy(currentActor);
                flashcard.setUpdatedBy(currentActor);
            }
            this.flashcardRepository.saveAll(activeFlashcards);
        }

        deck.setDeletedAt(Instant.now());
        deck.setNormalizedName(null);
        deck.setDeletedBy(currentActor);
        deck.setUpdatedBy(currentActor);
        this.deckRepository.save(deck);
    }

    private List<DeckResponse> toResponses(
            List<DeckEntity> entities,
            Map<Long, Long> flashcardCountByDeck,
            Map<String, String> actorDisplayNameByActor) {
        final List<DeckResponse> responses = new ArrayList<>();
        for (final DeckEntity entity : entities) {
            final long flashcardCount = flashcardCountByDeck.getOrDefault(entity.getId(), 0L);
            responses.add(toResponse(entity, flashcardCount, actorDisplayNameByActor));
        }
        return responses;
    }

    private DeckResponse toResponse(
            DeckEntity entity,
            long flashcardCount,
            Map<String, String> actorDisplayNameByActor) {
        return new DeckResponse(
                entity.getId(),
                entity.getFolderId(),
                entity.getName(),
                entity.getDescription(),
                flashcardCount,
                entity.getCreatedBy(),
                entity.getUpdatedBy(),
                resolveActorDisplayName(entity.getCreatedBy(), actorDisplayNameByActor),
                resolveActorDisplayName(entity.getUpdatedBy(), actorDisplayNameByActor),
                entity.getCreatedAt(),
                entity.getUpdatedAt());
    }

    private String resolveActorDisplayName(String actor, Map<String, String> actorDisplayNameByActor) {
        return actorDisplayNameByActor.getOrDefault(actor, actor);
    }

    private Map<String, String> resolveActorDisplayNameByActor(List<DeckEntity> entities) {
        final Set<String> actors = new HashSet<>();
        for (final DeckEntity entity : entities) {
            actors.add(entity.getCreatedBy());
            actors.add(entity.getUpdatedBy());
        }
        if (actors.isEmpty()) {
            return Map.of();
        }
        final Set<Long> actorIds = new HashSet<>();
        for (final String actor : actors) {
            final Long actorId = parseActorId(actor);
            if (actorId == null) {
                continue;
            }
            actorIds.add(actorId);
        }
        if (actorIds.isEmpty()) {
            return Map.of();
        }
        final Map<String, String> actorDisplayNameByActor = new HashMap<>();
        final List<AppUserEntity> users = this.appUserRepository.findAllById(actorIds);
        for (final AppUserEntity user : users) {
            actorDisplayNameByActor.put(String.valueOf(user.getId()), user.getDisplayName());
        }
        return actorDisplayNameByActor;
    }

    private Long parseActorId(String actor) {
        final String normalized = StringUtils.trimToEmpty(actor);
        if (normalized.isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(normalized);
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private Map<Long, Long> resolveFlashcardCountByDeck(List<DeckEntity> decks, String currentActor) {
        if (CollectionUtils.isEmpty(decks)) {
            return Map.of();
        }

        final List<Long> deckIds = new ArrayList<>();
        for (final DeckEntity deck : decks) {
            deckIds.add(deck.getId());
        }

        final var rows = this.flashcardRepository.countActiveFlashcardsByDeckIds(
                deckIds,
                currentActor);
        final Map<Long, Long> countByDeckId = new HashMap<>();
        for (final DeckFlashcardCountProjection row : rows) {
            countByDeckId.put(row.getDeckId(), row.getFlashcardCount());
        }
        return countByDeckId;
    }

    private void applyFlashcardDelta(Long folderId, int delta, Map<Long, FolderEntity> folderById,
            String currentActor) {
        final var currentFolder = folderById.get(folderId);
        if (currentFolder == null) {
            throw new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY);
        }

        var cursor = folderId;
        var isCurrentFolder = true;
        while (cursor != null) {
            final var folder = folderById.get(cursor);
            if (folder == null) {
                throw new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY);
            }

            if (isCurrentFolder) {
                final var updatedDirectCount = folder.getDirectFlashcardCount() + delta;
                if (updatedDirectCount < FolderConst.MIN_PAGE) {
                    throw new BusinessException(FolderConst.NEGATIVE_AGGREGATE_KEY);
                }
                folder.setDirectFlashcardCount(updatedDirectCount);
                isCurrentFolder = false;
            }

            final var updatedAggregateCount = folder.getAggregateFlashcardCount() + delta;
            if (updatedAggregateCount < FolderConst.MIN_PAGE) {
                throw new BusinessException(FolderConst.NEGATIVE_AGGREGATE_KEY);
            }
            folder.setAggregateFlashcardCount(updatedAggregateCount);
            folder.setUpdatedBy(currentActor);
            cursor = folder.getParentFolderId();
        }
    }

    private Map<Long, FolderEntity> toFolderById(List<FolderEntity> folders) {
        final Map<Long, FolderEntity> folderById = new HashMap<>();
        for (final FolderEntity folder : folders) {
            folderById.put(folder.getId(), folder);
        }
        return folderById;
    }

    private void validateFolderAllowsDeckCreation(Long folderId, String currentActor) {
        final var hasSubfolders = this.folderRepository.existsByParentFolderIdAndCreatedByAndDeletedAtIsNull(
                folderId,
                currentActor);
        if (!hasSubfolders) {
            return;
        }
        throw new BusinessException(DeckConst.FOLDER_HAS_SUBFOLDERS_KEY);
    }

    private void validateNameUniquenessForCreate(Long folderId, String normalizedNameForIndex, String currentActor) {
        final var hasDuplicateName = this.deckRepository.existsActiveByFolderAndNormalizedName(
                folderId,
                currentActor,
                normalizedNameForIndex);
        if (!hasDuplicateName) {
            return;
        }
        throw new BusinessException(DeckConst.DUPLICATE_NAME_KEY);
    }

    private void validateNameUniquenessForUpdate(
            Long folderId,
            Long deckId,
            String normalizedNameForIndex,
            String currentActor) {
        final var hasDuplicateName = this.deckRepository.existsActiveByFolderAndNormalizedNameExcludingDeckId(
                folderId,
                currentActor,
                normalizedNameForIndex,
                deckId);
        if (!hasDuplicateName) {
            return;
        }
        throw new BusinessException(DeckConst.DUPLICATE_NAME_KEY);
    }

    private DeckEntity persistDeckWithDuplicateNameGuard(DeckEntity deck) {
        try {
            return this.deckRepository.save(deck);
        } catch (final DataIntegrityViolationException exception) {
            log.warn(
                    LogConst.DECK_SERVICE_DUPLICATE_ACTIVE_NAME,
                    deck.getFolderId(),
                    deck.getName());
            throw new BusinessException(DeckConst.DUPLICATE_NAME_KEY);
        }
    }

    private DeckEntity getActiveDeckEntity(Long folderId, Long deckId, String currentActor) {
        getActiveFolderEntity(folderId, currentActor);
        return this.deckRepository
                .findByIdAndFolderIdAndCreatedByAndDeletedAtIsNull(deckId, folderId, currentActor)
                .orElseThrow(() -> new DeckNotFoundException(deckId));
    }

    private FolderEntity getActiveFolderEntity(Long folderId, String currentActor) {
        return this.folderRepository
                .findByIdAndCreatedByAndDeletedAtIsNull(folderId, currentActor)
                .orElseThrow(() -> new FolderNotFoundException(folderId));
    }

    private void validateRequest(String name, String description) {
        final var normalizedName = normalizeName(name);
        if (normalizedName.isEmpty()) {
            throw new BadRequestException(DeckConst.NAME_IS_REQUIRED_KEY);
        }
        if (normalizedName.length() > DeckConst.NAME_MAX_LENGTH) {
            throw new BadRequestException(DeckConst.NAME_TOO_LONG_KEY);
        }

        final var normalizedDescription = normalizeDescription(description);
        if (normalizedDescription.length() <= DeckConst.DESCRIPTION_MAX_LENGTH) {
            return;
        }
        throw new BadRequestException(DeckConst.DESCRIPTION_TOO_LONG_KEY);
    }

    private String normalizeName(String value) {
        return StringUtils.trimToEmpty(value);
    }

    private String normalizeNameForIndex(String value) {
        final var normalizedName = normalizeName(value);
        return normalizedName.toLowerCase(Locale.ROOT);
    }

    private String normalizeDescription(String value) {
        return StringUtils.trimToEmpty(value);
    }
}

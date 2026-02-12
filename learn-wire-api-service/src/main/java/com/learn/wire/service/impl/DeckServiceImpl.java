package com.learn.wire.service.impl;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.constant.DeckConst;
import com.learn.wire.constant.FolderConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.deck.query.DeckListQuery;
import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.request.DeckUpdateRequest;
import com.learn.wire.dto.deck.response.DeckResponse;
import com.learn.wire.entity.DeckEntity;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.FolderEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.DeckNotFoundException;
import com.learn.wire.exception.FolderNotFoundException;
import com.learn.wire.mapper.DeckMapper;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.FolderRepository;
import com.learn.wire.repository.FlashcardRepository.DeckFlashcardCountProjection;
import com.learn.wire.service.DeckService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class DeckServiceImpl implements DeckService {

    private final DeckRepository deckRepository;
    private final FolderRepository folderRepository;
    private final FlashcardRepository flashcardRepository;
    private final DeckMapper deckMapper;

    @Override
    @Transactional(readOnly = true)
    public PageResponse<DeckResponse> getDecks(DeckListQuery query) {
        log.debug(
                "Get decks with folderId={}, page={}, size={}, sortBy={}, sortDirection={}",
                query.folderId(),
                query.page(),
                query.size(),
                query.sortField().value(),
                query.sortDirection().value());
        getActiveFolderEntity(query.folderId());
        final Sort sort = Sort.by(query.sortDirection().toSpringDirection(), query.sortField().sortProperty());
        final Pageable pageable = PageRequest.of(query.page(), query.size(), sort);
        final Page<DeckEntity> page = this.deckRepository.findPageByFolderAndSearch(
                query.folderId(),
                query.search(),
                pageable);
        final Map<Long, Long> flashcardCountByDeck = resolveFlashcardCountByDeck(page.getContent());
        final List<DeckResponse> items = toResponses(page.getContent(), flashcardCountByDeck);
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
        final DeckEntity deck = getActiveDeckEntity(folderId, deckId);
        final long flashcardCount = this.flashcardRepository.countByDeckIdAndDeletedAtIsNull(deckId);
        return toResponse(deck, flashcardCount);
    }

    @Override
    public DeckResponse createDeck(Long folderId, DeckCreateRequest request) {
        log.info("Create deck in folderId={}", folderId);
        getActiveFolderEntity(folderId);
        validateRequest(request.name(), request.description());
        validateFolderAllowsDeckCreation(folderId);
        final String normalizedName = normalizeName(request.name());
        validateNameUniquenessForCreate(folderId, normalizedName);

        final DeckEntity entity = this.deckMapper.toEntity(request);
        entity.setFolderId(folderId);
        entity.setName(normalizedName);
        entity.setDescription(normalizeDescription(request.description()));
        entity.setCreatedBy(DeckConst.DEFAULT_ACTOR);
        entity.setUpdatedBy(DeckConst.DEFAULT_ACTOR);

        final DeckEntity created = this.deckRepository.save(entity);
        return toResponse(created, 0L);
    }

    @Override
    public DeckResponse updateDeck(Long folderId, Long deckId, DeckUpdateRequest request) {
        log.info("Update deck id={} in folderId={}", deckId, folderId);
        validateRequest(request.name(), request.description());
        final String normalizedName = normalizeName(request.name());
        final DeckEntity deck = getActiveDeckEntity(folderId, deckId);
        validateNameUniquenessForUpdate(folderId, deckId, normalizedName);
        this.deckMapper.updateEntity(request, deck);
        deck.setName(normalizedName);
        deck.setDescription(normalizeDescription(request.description()));
        deck.setUpdatedBy(DeckConst.DEFAULT_ACTOR);
        final DeckEntity updated = this.deckRepository.save(deck);
        final long flashcardCount = this.flashcardRepository.countByDeckIdAndDeletedAtIsNull(deckId);
        return toResponse(updated, flashcardCount);
    }

    @Override
    public void deleteDeck(Long folderId, Long deckId) {
        log.info("Delete deck id={} in folderId={}", deckId, folderId);
        final DeckEntity deck = getActiveDeckEntity(folderId, deckId);
        final List<FlashcardEntity> activeFlashcards = this.flashcardRepository.findByDeckIdAndDeletedAtIsNull(deckId);
        if (!activeFlashcards.isEmpty()) {
            final List<FolderEntity> activeFolders = this.folderRepository.findByDeletedAtIsNull();
            final Map<Long, FolderEntity> folderById = toFolderById(activeFolders);
            applyFlashcardDelta(deck.getFolderId(), -activeFlashcards.size(), folderById);
            this.folderRepository.saveAll(activeFolders);

            final Instant deletedAt = Instant.now();
            for (final FlashcardEntity flashcard : activeFlashcards) {
                flashcard.setDeletedAt(deletedAt);
                flashcard.setDeletedBy(DeckConst.DEFAULT_ACTOR);
                flashcard.setUpdatedBy(DeckConst.DEFAULT_ACTOR);
            }
            this.flashcardRepository.saveAll(activeFlashcards);
        }

        deck.setDeletedAt(Instant.now());
        deck.setDeletedBy(DeckConst.DEFAULT_ACTOR);
        deck.setUpdatedBy(DeckConst.DEFAULT_ACTOR);
        this.deckRepository.save(deck);
    }

    private List<DeckResponse> toResponses(
            List<DeckEntity> entities,
            Map<Long, Long> flashcardCountByDeck) {
        final List<DeckResponse> responses = new ArrayList<>();
        for (final DeckEntity entity : entities) {
            final long flashcardCount = flashcardCountByDeck.getOrDefault(entity.getId(), 0L);
            responses.add(toResponse(entity, flashcardCount));
        }
        return responses;
    }

    private DeckResponse toResponse(DeckEntity entity, long flashcardCount) {
        return new DeckResponse(
                entity.getId(),
                entity.getFolderId(),
                entity.getName(),
                entity.getDescription(),
                flashcardCount,
                entity.getCreatedBy(),
                entity.getUpdatedBy(),
                entity.getCreatedAt(),
                entity.getUpdatedAt());
    }

    private Map<Long, Long> resolveFlashcardCountByDeck(List<DeckEntity> decks) {
        if (CollectionUtils.isEmpty(decks)) {
            return Map.of();
        }

        final List<Long> deckIds = new ArrayList<>();
        for (final DeckEntity deck : decks) {
            deckIds.add(deck.getId());
        }

        final List<DeckFlashcardCountProjection> rows = this.flashcardRepository.countActiveFlashcardsByDeckIds(deckIds);
        final Map<Long, Long> countByDeckId = new HashMap<>();
        for (final DeckFlashcardCountProjection row : rows) {
            countByDeckId.put(row.getDeckId(), row.getFlashcardCount());
        }
        return countByDeckId;
    }

    private void applyFlashcardDelta(Long folderId, int delta, Map<Long, FolderEntity> folderById) {
        final FolderEntity currentFolder = folderById.get(folderId);
        if (currentFolder == null) {
            throw new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY);
        }

        Long cursor = folderId;
        boolean isCurrentFolder = true;
        while (cursor != null) {
            final FolderEntity folder = folderById.get(cursor);
            if (folder == null) {
                throw new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY);
            }

            if (isCurrentFolder) {
                final int updatedDirectCount = folder.getDirectFlashcardCount() + delta;
                if (updatedDirectCount < FolderConst.MIN_PAGE) {
                    throw new BusinessException(FolderConst.NEGATIVE_AGGREGATE_KEY);
                }
                folder.setDirectFlashcardCount(updatedDirectCount);
                isCurrentFolder = false;
            }

            final int updatedAggregateCount = folder.getAggregateFlashcardCount() + delta;
            if (updatedAggregateCount < FolderConst.MIN_PAGE) {
                throw new BusinessException(FolderConst.NEGATIVE_AGGREGATE_KEY);
            }
            folder.setAggregateFlashcardCount(updatedAggregateCount);
            folder.setUpdatedBy(FolderConst.DEFAULT_ACTOR);
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

    private void validateFolderAllowsDeckCreation(Long folderId) {
        final boolean hasSubfolders = this.folderRepository.existsByParentFolderIdAndDeletedAtIsNull(folderId);
        if (!hasSubfolders) {
            return;
        }
        throw new BusinessException(DeckConst.FOLDER_HAS_SUBFOLDERS_KEY);
    }

    private void validateNameUniquenessForCreate(Long folderId, String normalizedName) {
        final boolean hasDuplicateName = this.deckRepository.existsActiveByFolderAndName(folderId, normalizedName);
        if (!hasDuplicateName) {
            return;
        }
        throw new BusinessException(DeckConst.DUPLICATE_NAME_KEY);
    }

    private void validateNameUniquenessForUpdate(Long folderId, Long deckId, String normalizedName) {
        final boolean hasDuplicateName = this.deckRepository.existsActiveByFolderAndNameExcludingDeckId(
                folderId,
                normalizedName,
                deckId);
        if (!hasDuplicateName) {
            return;
        }
        throw new BusinessException(DeckConst.DUPLICATE_NAME_KEY);
    }

    private DeckEntity getActiveDeckEntity(Long folderId, Long deckId) {
        getActiveFolderEntity(folderId);
        return this.deckRepository
                .findByIdAndFolderIdAndDeletedAtIsNull(deckId, folderId)
                .orElseThrow(() -> new DeckNotFoundException(deckId));
    }

    private FolderEntity getActiveFolderEntity(Long folderId) {
        return this.folderRepository
                .findByIdAndDeletedAtIsNull(folderId)
                .orElseThrow(() -> new FolderNotFoundException(folderId));
    }

    private void validateRequest(String name, String description) {
        final String normalizedName = normalizeName(name);
        if (normalizedName.isEmpty()) {
            throw new BadRequestException(DeckConst.NAME_IS_REQUIRED_KEY);
        }
        if (normalizedName.length() > DeckConst.NAME_MAX_LENGTH) {
            throw new BadRequestException(DeckConst.NAME_TOO_LONG_KEY);
        }

        final String normalizedDescription = normalizeDescription(description);
        if (normalizedDescription.length() <= DeckConst.DESCRIPTION_MAX_LENGTH) {
            return;
        }
        throw new BadRequestException(DeckConst.DESCRIPTION_TOO_LONG_KEY);
    }

    private String normalizeName(String value) {
        return StringUtils.trimToEmpty(value);
    }

    private String normalizeDescription(String value) {
        return StringUtils.trimToEmpty(value);
    }
}

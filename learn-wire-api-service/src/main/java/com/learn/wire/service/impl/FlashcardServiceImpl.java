package com.learn.wire.service.impl;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.constant.FlashcardConst;
import com.learn.wire.constant.FolderConst;
import com.learn.wire.constant.LogConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.flashcard.query.FlashcardListQuery;
import com.learn.wire.dto.flashcard.query.FlashcardSortField;
import com.learn.wire.dto.flashcard.request.FlashcardCreateRequest;
import com.learn.wire.dto.flashcard.request.FlashcardUpdateRequest;
import com.learn.wire.dto.flashcard.response.FlashcardResponse;
import com.learn.wire.entity.DeckEntity;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.FolderEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.DeckNotFoundException;
import com.learn.wire.exception.FlashcardNotFoundException;
import com.learn.wire.mapper.FlashcardMapper;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.FolderRepository;
import com.learn.wire.security.CurrentUserAccessor;
import com.learn.wire.service.FlashcardService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class FlashcardServiceImpl implements FlashcardService {

    private final FlashcardRepository flashcardRepository;
    private final DeckRepository deckRepository;
    private final FolderRepository folderRepository;
    private final FlashcardMapper flashcardMapper;
    private final CurrentUserAccessor currentUserAccessor;

    @Override
    @Transactional(readOnly = true)
    public PageResponse<FlashcardResponse> getFlashcards(FlashcardListQuery query) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.debug(
                LogConst.FLASHCARD_SERVICE_GET_LIST,
                query.deckId(),
                query.page(),
                query.size(),
                query.sortField().value(),
                query.sortDirection().value());
        getActiveDeckEntity(query.deckId(), currentActor);
        final var sort = buildSort(query);
        final Pageable pageable = PageRequest.of(query.page(), query.size(), sort);
        final var page = this.flashcardRepository.findPageByDeckAndSearch(
                query.deckId(),
                currentActor,
                query.search(),
                pageable);
        final var items = toResponses(page.getContent());
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

    private Sort buildSort(FlashcardListQuery query) {
        final var primarySort = Sort.by(query.sortDirection().toSpringDirection(), query.sortField().sortProperty());
        if ((query.sortField() == FlashcardSortField.UPDATED_AT) && query.sortDirection().isDescending()) {
            final var tieBreakerSort = Sort.by(Sort.Direction.ASC, FlashcardConst.SORT_BY_TIE_BREAKER);
            return primarySort.and(tieBreakerSort);
        }
        final var tieBreakerSort = Sort.by(query.sortDirection().toSpringDirection(),
                FlashcardConst.SORT_BY_TIE_BREAKER);
        return primarySort.and(tieBreakerSort);
    }

    @Override
    public FlashcardResponse createFlashcard(Long deckId, FlashcardCreateRequest request) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.info(LogConst.FLASHCARD_SERVICE_CREATE, deckId);
        final var normalizedFrontText = normalizeText(request.frontText());
        final var normalizedBackText = normalizeText(request.backText());
        validateRequest(normalizedFrontText, normalizedBackText);

        final var deck = getActiveDeckEntity(deckId, currentActor);
        final var entity = this.flashcardMapper.toEntity(request);
        entity.setDeckId(deckId);
        entity.setFrontText(normalizedFrontText);
        entity.setBackText(normalizedBackText);
        entity.setCreatedBy(currentActor);
        entity.setUpdatedBy(currentActor);

        final var created = this.flashcardRepository.save(entity);
        final var activeFolders = this.folderRepository.findByCreatedByAndDeletedAtIsNull(currentActor);
        final var folderById = toFolderById(activeFolders);
        applyFlashcardDelta(deck.getFolderId(), 1, folderById, currentActor);
        this.folderRepository.saveAll(activeFolders);
        log.info(LogConst.FLASHCARD_SERVICE_CREATED, created.getId(), deckId);
        return toResponse(created);
    }

    @Override
    public FlashcardResponse updateFlashcard(Long deckId, Long flashcardId, FlashcardUpdateRequest request) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.info(LogConst.FLASHCARD_SERVICE_UPDATE, flashcardId, deckId);
        final var normalizedFrontText = normalizeText(request.frontText());
        final var normalizedBackText = normalizeText(request.backText());
        validateRequest(normalizedFrontText, normalizedBackText);

        final var entity = getActiveFlashcardEntity(deckId, flashcardId, currentActor);
        this.flashcardMapper.updateEntity(request, entity);
        entity.setFrontText(normalizedFrontText);
        entity.setBackText(normalizedBackText);
        entity.setUpdatedBy(currentActor);
        final var updated = this.flashcardRepository.save(entity);
        return toResponse(updated);
    }

    @Override
    public void deleteFlashcard(Long deckId, Long flashcardId) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.info(LogConst.FLASHCARD_SERVICE_DELETE, flashcardId, deckId);
        final var entity = getActiveFlashcardEntity(deckId, flashcardId, currentActor);
        final var deck = getActiveDeckEntity(deckId, currentActor);
        final var deletedAt = Instant.now();
        entity.setDeletedAt(deletedAt);
        entity.setDeletedBy(currentActor);
        entity.setUpdatedBy(currentActor);
        this.flashcardRepository.save(entity);

        final var activeFolders = this.folderRepository.findByCreatedByAndDeletedAtIsNull(currentActor);
        final var folderById = toFolderById(activeFolders);
        applyFlashcardDelta(deck.getFolderId(), -1, folderById, currentActor);
        this.folderRepository.saveAll(activeFolders);
    }

    private List<FlashcardResponse> toResponses(List<FlashcardEntity> entities) {
        final List<FlashcardResponse> responses = new ArrayList<>();
        for (final FlashcardEntity entity : entities) {
            responses.add(toResponse(entity));
        }
        return responses;
    }

    private FlashcardResponse toResponse(FlashcardEntity entity) {
        return new FlashcardResponse(
                entity.getId(),
                entity.getDeckId(),
                entity.getFrontText(),
                entity.getBackText(),
                entity.getCreatedBy(),
                entity.getUpdatedBy(),
                entity.getCreatedAt(),
                entity.getUpdatedAt());
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

    private DeckEntity getActiveDeckEntity(Long deckId, String currentActor) {
        return this.deckRepository
                .findByIdAndCreatedByAndDeletedAtIsNull(deckId, currentActor)
                .orElseThrow(() -> new DeckNotFoundException(deckId));
    }

    private FlashcardEntity getActiveFlashcardEntity(Long deckId, Long flashcardId, String currentActor) {
        getActiveDeckEntity(deckId, currentActor);
        return this.flashcardRepository
                .findByIdAndDeckIdAndCreatedByAndDeletedAtIsNull(flashcardId, deckId, currentActor)
                .orElseThrow(() -> new FlashcardNotFoundException(flashcardId));
    }

    private void validateRequest(String frontText, String backText) {
        if (frontText.isEmpty()) {
            throw new BadRequestException(FlashcardConst.FRONT_REQUIRED_KEY);
        }
        if (frontText.length() > FlashcardConst.FRONT_TEXT_MAX_LENGTH) {
            throw new BadRequestException(FlashcardConst.FRONT_TOO_LONG_KEY);
        }
        if (backText.isEmpty()) {
            throw new BadRequestException(FlashcardConst.BACK_REQUIRED_KEY);
        }
        if (backText.length() <= FlashcardConst.BACK_TEXT_MAX_LENGTH) {
            return;
        }
        throw new BadRequestException(FlashcardConst.BACK_TOO_LONG_KEY);
    }

    private String normalizeText(String value) {
        return StringUtils.trimToEmpty(value);
    }
}

package com.learn.wire.service.impl;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.constant.FlashcardConst;
import com.learn.wire.constant.FolderConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.flashcard.query.FlashcardListQuery;
import com.learn.wire.dto.flashcard.request.FlashcardCreateRequest;
import com.learn.wire.dto.flashcard.request.FlashcardUpdateRequest;
import com.learn.wire.dto.flashcard.response.FlashcardResponse;
import com.learn.wire.entity.FlashcardEntity;
import com.learn.wire.entity.FolderEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.FlashcardNotFoundException;
import com.learn.wire.exception.FolderNotFoundException;
import com.learn.wire.mapper.FlashcardMapper;
import com.learn.wire.repository.FlashcardRepository;
import com.learn.wire.repository.FolderRepository;
import com.learn.wire.service.FlashcardService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class FlashcardServiceImpl implements FlashcardService {

    private final FlashcardRepository flashcardRepository;
    private final FolderRepository folderRepository;
    private final FlashcardMapper flashcardMapper;

    @Override
    @Transactional(readOnly = true)
    public PageResponse<FlashcardResponse> getFlashcards(FlashcardListQuery query) {
        log.debug(
                "Get flashcards with folderId={}, page={}, size={}, sortBy={}, sortDirection={}",
                query.folderId(),
                query.page(),
                query.size(),
                query.sortField().value(),
                query.sortDirection().value());
        getActiveFolderEntity(query.folderId());
        final Sort sort = Sort.by(query.sortDirection().toSpringDirection(), query.sortField().sortProperty());
        final Pageable pageable = PageRequest.of(query.page(), query.size(), sort);
        final Page<FlashcardEntity> page = this.flashcardRepository.findPageByFolderAndSearch(
                query.folderId(),
                query.search(),
                pageable);
        final List<FlashcardResponse> items = toResponses(page.getContent());
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
    public FlashcardResponse createFlashcard(Long folderId, FlashcardCreateRequest request) {
        log.info("Create flashcard in folderId={}", folderId);
        final String normalizedFrontText = normalizeText(request.frontText());
        final String normalizedBackText = normalizeText(request.backText());
        validateRequest(normalizedFrontText, normalizedBackText);

        final FolderEntity folder = getActiveFolderEntity(folderId);
        validateFolderAllowsFlashcardCreation(folder);

        final FlashcardEntity entity = this.flashcardMapper.toEntity(request);
        entity.setFolderId(folderId);
        entity.setFrontText(normalizedFrontText);
        entity.setBackText(normalizedBackText);
        entity.setCreatedBy(FlashcardConst.DEFAULT_ACTOR);
        entity.setUpdatedBy(FlashcardConst.DEFAULT_ACTOR);

        final FlashcardEntity created = this.flashcardRepository.save(entity);
        final List<FolderEntity> activeFolders = this.folderRepository.findByDeletedAtIsNull();
        final Map<Long, FolderEntity> folderById = toFolderById(activeFolders);
        applyFlashcardDelta(folderId, 1, folderById);
        this.folderRepository.saveAll(activeFolders);
        log.info("Created flashcard id={} in folderId={}", created.getId(), folderId);
        return toResponse(created);
    }

    @Override
    public FlashcardResponse updateFlashcard(Long folderId, Long flashcardId, FlashcardUpdateRequest request) {
        log.info("Update flashcard id={} in folderId={}", flashcardId, folderId);
        final String normalizedFrontText = normalizeText(request.frontText());
        final String normalizedBackText = normalizeText(request.backText());
        validateRequest(normalizedFrontText, normalizedBackText);

        final FlashcardEntity entity = getActiveFlashcardEntity(folderId, flashcardId);
        this.flashcardMapper.updateEntity(request, entity);
        entity.setFrontText(normalizedFrontText);
        entity.setBackText(normalizedBackText);
        entity.setUpdatedBy(FlashcardConst.DEFAULT_ACTOR);
        final FlashcardEntity updated = this.flashcardRepository.save(entity);
        return toResponse(updated);
    }

    @Override
    public void deleteFlashcard(Long folderId, Long flashcardId) {
        log.info("Delete flashcard id={} in folderId={}", flashcardId, folderId);
        final FlashcardEntity entity = getActiveFlashcardEntity(folderId, flashcardId);
        final Instant deletedAt = Instant.now();
        entity.setDeletedAt(deletedAt);
        entity.setDeletedBy(FlashcardConst.DEFAULT_ACTOR);
        entity.setUpdatedBy(FlashcardConst.DEFAULT_ACTOR);
        this.flashcardRepository.save(entity);

        final List<FolderEntity> activeFolders = this.folderRepository.findByDeletedAtIsNull();
        final Map<Long, FolderEntity> folderById = toFolderById(activeFolders);
        applyFlashcardDelta(folderId, -1, folderById);
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
                entity.getFolderId(),
                entity.getFrontText(),
                entity.getBackText(),
                entity.getCreatedBy(),
                entity.getUpdatedBy(),
                entity.getCreatedAt(),
                entity.getUpdatedAt());
    }

    private void validateFolderAllowsFlashcardCreation(FolderEntity folder) {
        final boolean hasDirectChildren = this.folderRepository.existsByParentFolderIdAndDeletedAtIsNull(folder.getId());
        if (!hasDirectChildren) {
            return;
        }
        throw new BusinessException(FlashcardConst.FOLDER_HAS_SUBFOLDERS_KEY);
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

    private FolderEntity getActiveFolderEntity(Long folderId) {
        return this.folderRepository
                .findByIdAndDeletedAtIsNull(folderId)
                .orElseThrow(() -> new FolderNotFoundException(folderId));
    }

    private FlashcardEntity getActiveFlashcardEntity(Long folderId, Long flashcardId) {
        getActiveFolderEntity(folderId);
        return this.flashcardRepository
                .findByIdAndFolderIdAndDeletedAtIsNull(flashcardId, folderId)
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
        if (backText.length() > FlashcardConst.BACK_TEXT_MAX_LENGTH) {
            throw new BadRequestException(FlashcardConst.BACK_TOO_LONG_KEY);
        }
    }

    private String normalizeText(String value) {
        return StringUtils.trimToEmpty(value);
    }
}

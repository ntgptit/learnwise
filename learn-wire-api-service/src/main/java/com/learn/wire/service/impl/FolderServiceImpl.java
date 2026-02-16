package com.learn.wire.service.impl;

import java.time.Instant;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.constant.FolderConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.folder.query.FolderListQuery;
import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.request.FolderUpdateRequest;
import com.learn.wire.dto.folder.response.FolderResponse;
import com.learn.wire.entity.FolderEntity;
import com.learn.wire.exception.BadRequestException;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.FolderNotFoundException;
import com.learn.wire.mapper.FolderMapper;
import com.learn.wire.repository.DeckRepository;
import com.learn.wire.repository.DeckRepository.FolderDeckCountProjection;
import com.learn.wire.repository.FolderRepository;
import com.learn.wire.repository.FolderRepository.ParentChildCountProjection;
import com.learn.wire.security.CurrentUserAccessor;
import com.learn.wire.service.FolderService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class FolderServiceImpl implements FolderService {

    private final FolderRepository repository;
    private final DeckRepository deckRepository;
    private final FolderMapper mapper;
    private final CurrentUserAccessor currentUserAccessor;

    @Override
    @Transactional(readOnly = true)
    public PageResponse<FolderResponse> getFolders(FolderListQuery query) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.debug(
                "Get folders with page={}, size={}, parentFolderId={}, sortBy={}, sortDirection={}",
                query.page(),
                query.size(),
                query.parentFolderId(),
                query.sortField().value(),
                query.sortDirection().value());
        validateParentFilter(query.parentFolderId(), currentActor);

        final var page = findPageSortedByDatabase(query, currentActor);
        final var childCountByParent = resolveChildCountByParent(page.getContent(), currentActor);
        final var directDeckCountByFolder = resolveDirectDeckCountByFolder(page.getContent(),
                currentActor);
        final var items = toResponses(page.getContent(), childCountByParent, directDeckCountByFolder);

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
    public FolderResponse getFolder(Long folderId) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.debug("Get folder id={}", folderId);
        final var entity = getActiveFolderEntity(folderId, currentActor);
        final var childFolderCount = resolveChildFolderCount(folderId, currentActor);
        final var directDeckCount = resolveDirectDeckCount(folderId, currentActor);
        return toResponse(entity, childFolderCount, directDeckCount);
    }

    @Override
    public FolderResponse createFolder(FolderCreateRequest request) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.info("Create folder with parentFolderId={}", request.parentFolderId());
        validateRequest(request.name(), request.description(), request.colorHex());
        validateParentAllowsSubfolderCreation(request.parentFolderId(), currentActor);
        final var normalizedName = normalizeName(request.name());
        validateNameUniquenessForCreate(normalizedName, request.parentFolderId(), currentActor);

        final var entity = this.mapper.toEntity(request);
        entity.setName(normalizedName);
        entity.setDescription(normalizeDescription(request.description()));
        entity.setColorHex(normalizeColorHex(request.colorHex()));
        entity.setParentFolderId(request.parentFolderId());
        entity.setDirectFlashcardCount(FolderConst.DEFAULT_DIRECT_FLASHCARD_COUNT);
        entity.setAggregateFlashcardCount(FolderConst.DEFAULT_DIRECT_FLASHCARD_COUNT);
        entity.setCreatedBy(currentActor);
        entity.setUpdatedBy(currentActor);

        final var created = this.repository.save(entity);
        log.info("Created folder id={}", created.getId());
        return toResponse(created, FolderConst.MIN_PAGE, FolderConst.MIN_PAGE);
    }

    @Override
    public FolderResponse updateFolder(Long folderId, FolderUpdateRequest request) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.info("Update folder id={} with new parent={}", folderId, request.parentFolderId());
        validateRequest(request.name(), request.description(), request.colorHex());
        final var normalizedName = normalizeName(request.name());

        final var entity = getActiveFolderEntity(folderId, currentActor);
        final var oldParentFolderId = entity.getParentFolderId();
        final var newParentFolderId = request.parentFolderId();
        final var subtreeAggregate = entity.getAggregateFlashcardCount();

        final var activeFolders = this.repository.findByCreatedByAndDeletedAtIsNull(currentActor);
        final var folderById = toFolderById(activeFolders);
        validateParentForUpdate(folderId, newParentFolderId, folderById);
        validateNameUniquenessForUpdate(folderId, normalizedName, newParentFolderId, currentActor);
        final var isParentChanged = !isSameParent(oldParentFolderId, newParentFolderId);

        if (isParentChanged) {
            validateParentAllowsSubfolderCreationForUpdate(newParentFolderId, folderById, currentActor);
            applyAggregateDeltaToAncestors(oldParentFolderId, -subtreeAggregate, folderById, currentActor);
            applyAggregateDeltaToAncestors(newParentFolderId, subtreeAggregate, folderById, currentActor);
        }

        this.mapper.updateEntity(request, entity);
        entity.setName(normalizedName);
        entity.setDescription(normalizeDescription(request.description()));
        entity.setColorHex(normalizeColorHex(request.colorHex()));
        entity.setParentFolderId(newParentFolderId);
        entity.setUpdatedBy(currentActor);

        final var updated = this.repository.save(entity);
        log.info("Updated folder id={}", updated.getId());
        final var childFolderCount = resolveChildFolderCount(updated.getId(), currentActor);
        final var directDeckCount = resolveDirectDeckCount(updated.getId(), currentActor);
        return toResponse(updated, childFolderCount, directDeckCount);
    }

    @Override
    public void deleteFolder(Long folderId) {
        final String currentActor = this.currentUserAccessor.getCurrentActor();
        log.info("Delete folder id={}", folderId);
        final var target = getActiveFolderEntity(folderId, currentActor);
        final var subtreeAggregate = target.getAggregateFlashcardCount();

        final var activeFolders = this.repository.findByCreatedByAndDeletedAtIsNull(currentActor);
        final var folderById = toFolderById(activeFolders);
        final var childrenByParentId = toChildrenByParent(activeFolders);
        applyAggregateDeltaToAncestors(target.getParentFolderId(), -subtreeAggregate, folderById, currentActor);

        final var toDelete = collectSubtree(target, childrenByParentId);
        final var deletedAt = Instant.now();
        for (final FolderEntity entity : toDelete) {
            entity.setDeletedAt(deletedAt);
            entity.setDeletedBy(currentActor);
            entity.setUpdatedBy(currentActor);
        }
        this.repository.saveAll(toDelete);
        log.info("Soft deleted subtree rootId={} affectedCount={}", folderId, toDelete.size());
    }

    private Page<FolderEntity> findPageSortedByDatabase(FolderListQuery query, String currentActor) {
        final var sort = Sort
                .by(query.sortDirection().toSpringDirection(), query.sortField().sortProperty())
                .and(Sort.by(query.sortDirection().toSpringDirection(), FolderConst.SORT_BY_TIE_BREAKER));
        final Pageable pageable = PageRequest.of(query.page(), query.size(), sort);
        return this.repository.findPageByParentAndSearch(query.parentFolderId(), currentActor, query.search(),
                pageable);
    }

    private List<FolderResponse> toResponses(
            List<FolderEntity> entities,
            Map<Long, Integer> childCountByParent,
            Map<Long, Integer> directDeckCountByFolder) {
        final List<FolderResponse> responses = new ArrayList<>();
        for (final FolderEntity entity : entities) {
            final int childFolderCount = childCountByParent.getOrDefault(entity.getId(), FolderConst.MIN_PAGE);
            final int directDeckCount = directDeckCountByFolder.getOrDefault(entity.getId(), FolderConst.MIN_PAGE);
            responses.add(toResponse(entity, childFolderCount, directDeckCount));
        }
        return responses;
    }

    private FolderResponse toResponse(FolderEntity entity, int childFolderCount, int directDeckCount) {
        return new FolderResponse(
                entity.getId(),
                entity.getName(),
                entity.getDescription(),
                entity.getColorHex(),
                entity.getParentFolderId(),
                entity.getDirectFlashcardCount(),
                entity.getAggregateFlashcardCount(),
                childFolderCount,
                directDeckCount,
                entity.getCreatedBy(),
                entity.getUpdatedBy(),
                entity.getCreatedAt(),
                entity.getUpdatedAt());
    }

    private Map<Long, Integer> resolveDirectDeckCountByFolder(List<FolderEntity> folders, String currentActor) {
        if (CollectionUtils.isEmpty(folders)) {
            return Map.of();
        }

        final List<Long> folderIds = new ArrayList<>();
        for (final FolderEntity folder : folders) {
            folderIds.add(folder.getId());
        }

        final var rows = this.deckRepository.countActiveDecksByFolderIds(folderIds,
                currentActor);
        final Map<Long, Integer> countByFolder = new HashMap<>();
        for (final FolderDeckCountProjection row : rows) {
            countByFolder.put(row.getFolderId(), (int) row.getDeckCount());
        }
        return countByFolder;
    }

    private int resolveDirectDeckCount(Long folderId, String currentActor) {
        final var rows = this.deckRepository.countActiveDecksByFolderIds(
                List.of(folderId),
                currentActor);
        if (rows.isEmpty()) {
            return FolderConst.MIN_PAGE;
        }
        return (int) rows.get(FolderConst.MIN_PAGE).getDeckCount();
    }

    private Map<Long, Integer> resolveChildCountByParent(List<FolderEntity> parents, String currentActor) {
        if (CollectionUtils.isEmpty(parents)) {
            return Map.of();
        }

        final List<Long> parentIds = new ArrayList<>();
        for (final FolderEntity parent : parents) {
            parentIds.add(parent.getId());
        }

        final var rows = this.repository.countActiveChildrenByParentIds(parentIds,
                currentActor);
        final Map<Long, Integer> childCountByParent = new HashMap<>();
        for (final ParentChildCountProjection row : rows) {
            childCountByParent.put(row.getParentFolderId(), (int) row.getChildCount());
        }
        return childCountByParent;
    }

    private int resolveChildFolderCount(Long parentFolderId, String currentActor) {
        final var rows = this.repository.countActiveChildrenByParentIds(
                List.of(parentFolderId),
                currentActor);
        if (rows.isEmpty()) {
            return FolderConst.MIN_PAGE;
        }
        return (int) rows.get(FolderConst.MIN_PAGE).getChildCount();
    }

    private void applyAggregateDeltaToAncestors(
            Long startParentFolderId,
            int delta,
            Map<Long, FolderEntity> folderById,
            String currentActor) {
        var cursor = startParentFolderId;
        while (cursor != null) {
            final var ancestor = folderById.get(cursor);
            if (ancestor == null) {
                return;
            }

            final var updatedAggregate = ancestor.getAggregateFlashcardCount() + delta;
            if (updatedAggregate < FolderConst.MIN_PAGE) {
                throw new BusinessException(FolderConst.NEGATIVE_AGGREGATE_KEY);
            }
            ancestor.setAggregateFlashcardCount(updatedAggregate);
            ancestor.setUpdatedBy(currentActor);
            cursor = ancestor.getParentFolderId();
        }
    }

    private List<FolderEntity> collectSubtree(
            FolderEntity root,
            Map<Long, List<FolderEntity>> childrenByParentId) {
        final List<FolderEntity> nodes = new ArrayList<>();
        final var stack = new ArrayDeque<FolderEntity>();
        stack.push(root);

        while (!stack.isEmpty()) {
            final var current = stack.pop();
            nodes.add(current);

            final var children = childrenByParentId.get(current.getId());
            if (children == null) {
                continue;
            }
            for (final FolderEntity child : children) {
                stack.push(child);
            }
        }
        return nodes;
    }

    private Map<Long, FolderEntity> toFolderById(List<FolderEntity> folders) {
        final Map<Long, FolderEntity> folderById = new HashMap<>();
        for (final FolderEntity folder : folders) {
            folderById.put(folder.getId(), folder);
        }
        return folderById;
    }

    private Map<Long, List<FolderEntity>> toChildrenByParent(List<FolderEntity> folders) {
        final Map<Long, List<FolderEntity>> childrenByParentId = new HashMap<>();
        for (final FolderEntity folder : folders) {
            final var parentFolderId = folder.getParentFolderId();
            final var children = childrenByParentId.computeIfAbsent(
                    parentFolderId,
                    ignored -> new ArrayList<>());
            children.add(folder);
        }
        return childrenByParentId;
    }

    private void validateParentFilter(Long parentFolderId, String currentActor) {
        if (parentFolderId == null) {
            return;
        }
        validateParentExists(parentFolderId, currentActor);
    }

    private void validateParentExists(Long parentFolderId, String currentActor) {
        if (this.repository.findByIdAndCreatedByAndDeletedAtIsNull(parentFolderId, currentActor).isPresent()) {
            return;
        }
        throw new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY);
    }

    private void validateParentForUpdate(
            Long folderId,
            Long parentFolderId,
            Map<Long, FolderEntity> folderById) {
        if (parentFolderId == null) {
            return;
        }
        if (folderId.equals(parentFolderId)) {
            throw new BadRequestException(FolderConst.PARENT_SELF_KEY);
        }
        if (!folderById.containsKey(parentFolderId)) {
            throw new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY);
        }

        var cursor = parentFolderId;
        while (cursor != null) {
            if (cursor.equals(folderId)) {
                throw new BadRequestException(FolderConst.PARENT_CYCLE_KEY);
            }
            final var current = folderById.get(cursor);
            if (current == null) {
                break;
            }
            cursor = current.getParentFolderId();
        }
    }

    private void validateParentAllowsSubfolderCreation(Long parentFolderId, String currentActor) {
        if (parentFolderId == null) {
            return;
        }
        this.repository
                .findByIdAndCreatedByAndDeletedAtIsNull(parentFolderId, currentActor)
                .orElseThrow(() -> new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY));
        final var hasDirectDecks = this.deckRepository.existsByFolderIdAndCreatedByAndDeletedAtIsNull(
                parentFolderId,
                currentActor);
        if (!hasDirectDecks) {
            return;
        }
        throw new BusinessException(FolderConst.PARENT_HAS_DECKS_KEY);
    }

    private void validateParentAllowsSubfolderCreationForUpdate(
            Long parentFolderId,
            Map<Long, FolderEntity> folderById,
            String currentActor) {
        if (parentFolderId == null) {
            return;
        }
        if (!folderById.containsKey(parentFolderId)) {
            throw new BadRequestException(FolderConst.PARENT_NOT_FOUND_KEY);
        }
        final var hasDirectDecks = this.deckRepository.existsByFolderIdAndCreatedByAndDeletedAtIsNull(
                parentFolderId,
                currentActor);
        if (!hasDirectDecks) {
            return;
        }
        throw new BusinessException(FolderConst.PARENT_HAS_DECKS_KEY);
    }

    private boolean isSameParent(Long value, Long expected) {
        if ((value == null) && (expected == null)) {
            return true;
        }
        if ((value == null) || (expected == null)) {
            return false;
        }
        return value.equals(expected);
    }

    private void validateNameUniquenessForCreate(String normalizedName, Long parentFolderId, String currentActor) {
        final var hasDuplicateName = this.repository.existsActiveByParentAndName(
                parentFolderId,
                currentActor,
                normalizedName);
        if (!hasDuplicateName) {
            return;
        }
        throw new BusinessException(FolderConst.DUPLICATE_NAME_KEY);
    }

    private void validateNameUniquenessForUpdate(
            Long folderId,
            String normalizedName,
            Long parentFolderId,
            String currentActor) {
        final var hasDuplicateName = this.repository.existsActiveByParentAndNameExcludingFolderId(
                parentFolderId,
                currentActor,
                normalizedName,
                folderId);
        if (!hasDuplicateName) {
            return;
        }
        throw new BusinessException(FolderConst.DUPLICATE_NAME_KEY);
    }

    private FolderEntity getActiveFolderEntity(Long folderId, String currentActor) {
        return this.repository
                .findByIdAndCreatedByAndDeletedAtIsNull(folderId, currentActor)
                .orElseThrow(() -> new FolderNotFoundException(folderId));
    }

    private void validateRequest(String name, String description, String colorHex) {
        final var normalizedName = normalizeName(name);
        if (normalizedName.isEmpty()) {
            throw new BadRequestException(FolderConst.NAME_IS_REQUIRED_KEY);
        }
        if (normalizedName.length() > FolderConst.NAME_MAX_LENGTH) {
            throw new BadRequestException(FolderConst.NAME_TOO_LONG_KEY);
        }

        final var normalizedDescription = normalizeDescription(description);
        if (normalizedDescription.length() > FolderConst.DESCRIPTION_MAX_LENGTH) {
            throw new BadRequestException(FolderConst.DESCRIPTION_TOO_LONG_KEY);
        }

        final var normalizedColorHex = normalizeColorHex(colorHex);
        if (normalizedColorHex.matches(FolderConst.COLOR_HEX_PATTERN)) {
            return;
        }
        throw new BadRequestException(FolderConst.COLOR_HEX_INVALID_KEY);
    }

    private String normalizeName(String value) {
        return StringUtils.trimToEmpty(value);
    }

    private String normalizeDescription(String value) {
        return StringUtils.trimToEmpty(value);
    }

    private String normalizeColorHex(String value) {
        final var normalized = StringUtils.trimToEmpty(value);
        if (normalized.isEmpty()) {
            return FolderConst.DEFAULT_COLOR_HEX;
        }
        return normalized.toUpperCase(Locale.ROOT);
    }
}

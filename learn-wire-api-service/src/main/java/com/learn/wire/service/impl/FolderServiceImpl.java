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
import com.learn.wire.repository.FolderRepository;
import com.learn.wire.repository.FolderRepository.ParentChildCountProjection;
import com.learn.wire.service.FolderService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class FolderServiceImpl implements FolderService {

    private final FolderRepository repository;
    private final FolderMapper mapper;

    @Override
    @Transactional(readOnly = true)
    public PageResponse<FolderResponse> getFolders(FolderListQuery query) {
        log.debug(
                "Get folders with page={}, size={}, parentFolderId={}, sortBy={}, sortDirection={}",
                query.page(),
                query.size(),
                query.parentFolderId(),
                query.sortField().value(),
                query.sortDirection().value());
        validateParentFilter(query.parentFolderId());

        final Page<FolderEntity> page = findPageSortedByDatabase(query);
        final Map<Long, Integer> childCountByParent = resolveChildCountByParent(page.getContent());
        final List<FolderResponse> items = toResponses(page.getContent(), childCountByParent);

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
        log.debug("Get folder id={}", folderId);
        final FolderEntity entity = getActiveFolderEntity(folderId);
        final int childFolderCount = resolveChildFolderCount(folderId);
        return toResponse(entity, childFolderCount);
    }

    @Override
    public FolderResponse createFolder(FolderCreateRequest request) {
        log.info("Create folder with parentFolderId={}", request.parentFolderId());
        validateRequest(request.name(), request.description(), request.colorHex());
        validateParentFilter(request.parentFolderId());

        final FolderEntity entity = this.mapper.toEntity(request);
        entity.setName(normalizeName(request.name()));
        entity.setDescription(normalizeDescription(request.description()));
        entity.setColorHex(normalizeColorHex(request.colorHex()));
        entity.setParentFolderId(request.parentFolderId());
        entity.setDirectFlashcardCount(FolderConst.DEFAULT_DIRECT_FLASHCARD_COUNT);
        entity.setAggregateFlashcardCount(FolderConst.DEFAULT_DIRECT_FLASHCARD_COUNT);
        entity.setCreatedBy(FolderConst.DEFAULT_ACTOR);
        entity.setUpdatedBy(FolderConst.DEFAULT_ACTOR);

        final FolderEntity created = this.repository.save(entity);
        log.info("Created folder id={}", created.getId());
        return toResponse(created, FolderConst.MIN_PAGE);
    }

    @Override
    public FolderResponse updateFolder(Long folderId, FolderUpdateRequest request) {
        log.info("Update folder id={} with new parent={}", folderId, request.parentFolderId());
        validateRequest(request.name(), request.description(), request.colorHex());

        final FolderEntity entity = getActiveFolderEntity(folderId);
        final Long oldParentFolderId = entity.getParentFolderId();
        final Long newParentFolderId = request.parentFolderId();
        final int subtreeAggregate = entity.getAggregateFlashcardCount();

        final List<FolderEntity> activeFolders = this.repository.findByDeletedAtIsNull();
        final Map<Long, FolderEntity> folderById = toFolderById(activeFolders);
        validateParentForUpdate(folderId, newParentFolderId, folderById);

        if (!isSameParent(oldParentFolderId, newParentFolderId)) {
            applyAggregateDeltaToAncestors(oldParentFolderId, -subtreeAggregate, folderById);
            applyAggregateDeltaToAncestors(newParentFolderId, subtreeAggregate, folderById);
        }

        this.mapper.updateEntity(request, entity);
        entity.setName(normalizeName(request.name()));
        entity.setDescription(normalizeDescription(request.description()));
        entity.setColorHex(normalizeColorHex(request.colorHex()));
        entity.setParentFolderId(newParentFolderId);
        entity.setUpdatedBy(FolderConst.DEFAULT_ACTOR);

        final FolderEntity updated = this.repository.save(entity);
        log.info("Updated folder id={}", updated.getId());
        final int childFolderCount = resolveChildFolderCount(updated.getId());
        return toResponse(updated, childFolderCount);
    }

    @Override
    public void deleteFolder(Long folderId) {
        log.info("Delete folder id={}", folderId);
        final FolderEntity target = getActiveFolderEntity(folderId);
        final int subtreeAggregate = target.getAggregateFlashcardCount();

        final List<FolderEntity> activeFolders = this.repository.findByDeletedAtIsNull();
        final Map<Long, FolderEntity> folderById = toFolderById(activeFolders);
        final Map<Long, List<FolderEntity>> childrenByParentId = toChildrenByParent(activeFolders);
        applyAggregateDeltaToAncestors(target.getParentFolderId(), -subtreeAggregate, folderById);

        final List<FolderEntity> toDelete = collectSubtree(target, childrenByParentId);
        final Instant deletedAt = Instant.now();
        for (final FolderEntity entity : toDelete) {
            entity.setDeletedAt(deletedAt);
            entity.setDeletedBy(FolderConst.DEFAULT_ACTOR);
            entity.setUpdatedBy(FolderConst.DEFAULT_ACTOR);
        }
        this.repository.saveAll(toDelete);
        log.info("Soft deleted subtree rootId={} affectedCount={}", folderId, toDelete.size());
    }

    private Page<FolderEntity> findPageSortedByDatabase(FolderListQuery query) {
        final Sort sort = Sort.by(query.sortDirection().toSpringDirection(), query.sortField().sortProperty());
        final Pageable pageable = PageRequest.of(query.page(), query.size(), sort);
        return this.repository.findPageByParentAndSearch(query.parentFolderId(), query.search(), pageable);
    }

    private List<FolderResponse> toResponses(
            List<FolderEntity> entities,
            Map<Long, Integer> childCountByParent) {
        final List<FolderResponse> responses = new ArrayList<>();
        for (final FolderEntity entity : entities) {
            final int childFolderCount = childCountByParent.getOrDefault(entity.getId(), FolderConst.MIN_PAGE);
            responses.add(toResponse(entity, childFolderCount));
        }
        return responses;
    }

    private FolderResponse toResponse(FolderEntity entity, int childFolderCount) {
        return new FolderResponse(
                entity.getId(),
                entity.getName(),
                entity.getDescription(),
                entity.getColorHex(),
                entity.getParentFolderId(),
                entity.getAggregateFlashcardCount(),
                childFolderCount,
                entity.getCreatedBy(),
                entity.getUpdatedBy(),
                entity.getCreatedAt(),
                entity.getUpdatedAt());
    }

    private Map<Long, Integer> resolveChildCountByParent(List<FolderEntity> parents) {
        if (CollectionUtils.isEmpty(parents)) {
            return Map.of();
        }

        final List<Long> parentIds = new ArrayList<>();
        for (final FolderEntity parent : parents) {
            parentIds.add(parent.getId());
        }

        final List<ParentChildCountProjection> rows = this.repository.countActiveChildrenByParentIds(parentIds);
        final Map<Long, Integer> childCountByParent = new HashMap<>();
        for (final ParentChildCountProjection row : rows) {
            childCountByParent.put(row.getParentFolderId(), (int) row.getChildCount());
        }
        return childCountByParent;
    }

    private int resolveChildFolderCount(Long parentFolderId) {
        final List<ParentChildCountProjection> rows = this.repository.countActiveChildrenByParentIds(List.of(parentFolderId));
        if (rows.isEmpty()) {
            return FolderConst.MIN_PAGE;
        }
        return (int) rows.get(FolderConst.MIN_PAGE).getChildCount();
    }

    private void applyAggregateDeltaToAncestors(
            Long startParentFolderId,
            int delta,
            Map<Long, FolderEntity> folderById) {
        Long cursor = startParentFolderId;
        while (cursor != null) {
            final FolderEntity ancestor = folderById.get(cursor);
            if (ancestor == null) {
                return;
            }

            final int updatedAggregate = ancestor.getAggregateFlashcardCount() + delta;
            if (updatedAggregate < FolderConst.MIN_PAGE) {
                throw new BusinessException(FolderConst.NEGATIVE_AGGREGATE_KEY);
            }
            ancestor.setAggregateFlashcardCount(updatedAggregate);
            ancestor.setUpdatedBy(FolderConst.DEFAULT_ACTOR);
            cursor = ancestor.getParentFolderId();
        }
    }

    private List<FolderEntity> collectSubtree(
            FolderEntity root,
            Map<Long, List<FolderEntity>> childrenByParentId) {
        final List<FolderEntity> nodes = new ArrayList<>();
        final ArrayDeque<FolderEntity> stack = new ArrayDeque<>();
        stack.push(root);

        while (!stack.isEmpty()) {
            final FolderEntity current = stack.pop();
            nodes.add(current);

            final List<FolderEntity> children = childrenByParentId.get(current.getId());
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
            final Long parentFolderId = folder.getParentFolderId();
            final List<FolderEntity> children = childrenByParentId.computeIfAbsent(
                    parentFolderId,
                    ignored -> new ArrayList<>());
            children.add(folder);
        }
        return childrenByParentId;
    }

    private void validateParentFilter(Long parentFolderId) {
        if (parentFolderId == null) {
            return;
        }
        validateParentExists(parentFolderId);
    }

    private void validateParentExists(Long parentFolderId) {
        if (this.repository.findByIdAndDeletedAtIsNull(parentFolderId).isPresent()) {
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

        Long cursor = parentFolderId;
        while (cursor != null) {
            if (cursor.equals(folderId)) {
                throw new BadRequestException(FolderConst.PARENT_CYCLE_KEY);
            }
            final FolderEntity current = folderById.get(cursor);
            if (current == null) {
                break;
            }
            cursor = current.getParentFolderId();
        }
    }

    private boolean isSameParent(Long value, Long expected) {
        if (value == null && expected == null) {
            return true;
        }
        if (value == null || expected == null) {
            return false;
        }
        return value.equals(expected);
    }

    private FolderEntity getActiveFolderEntity(Long folderId) {
        return this.repository
                .findByIdAndDeletedAtIsNull(folderId)
                .orElseThrow(() -> new FolderNotFoundException(folderId));
    }

    private void validateRequest(String name, String description, String colorHex) {
        final String normalizedName = normalizeName(name);
        if (normalizedName.isEmpty()) {
            throw new BadRequestException(FolderConst.NAME_IS_REQUIRED_KEY);
        }
        if (normalizedName.length() > FolderConst.NAME_MAX_LENGTH) {
            throw new BadRequestException(FolderConst.NAME_TOO_LONG_KEY);
        }

        final String normalizedDescription = normalizeDescription(description);
        if (normalizedDescription.length() > FolderConst.DESCRIPTION_MAX_LENGTH) {
            throw new BadRequestException(FolderConst.DESCRIPTION_TOO_LONG_KEY);
        }

        final String normalizedColorHex = normalizeColorHex(colorHex);
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
        final String normalized = StringUtils.trimToEmpty(value);
        if (normalized.isEmpty()) {
            return FolderConst.DEFAULT_COLOR_HEX;
        }
        return normalized.toUpperCase(Locale.ROOT);
    }
}


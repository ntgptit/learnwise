package com.learn.wire.dto.folder.query;

import com.learn.wire.constant.FolderConst;
import com.learn.wire.constant.ErrorMessageConst;
import com.learn.wire.dto.common.query.SortDirection;
import com.learn.wire.dto.folder.request.FolderListRequest;
import com.learn.wire.exception.BadRequestException;

public record FolderListQuery(
        int page,
        int size,
        String search,
        Long parentFolderId,
        FolderSortField sortField,
        SortDirection sortDirection) {

    public static FolderListQuery fromRequest(FolderListRequest request) {
        if (request == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }

        final int page = request.getPage();
        if (page < FolderConst.MIN_PAGE) {
            throw new BadRequestException(FolderConst.PAGE_INVALID_KEY);
        }

        final int size = request.getSize();
        if ((size < FolderConst.MIN_SIZE) || (size > FolderConst.MAX_SIZE)) {
            throw new BadRequestException(FolderConst.SIZE_INVALID_KEY);
        }

        final var resolvedSortField = FolderSortField.fromValue(request.getSortBy());
        final var resolvedSortDirection = SortDirection.fromRaw(
                request.getSortDirection(),
                FolderConst.SORT_DIRECTION_INVALID_KEY);
        final var normalizedSearch = normalizeSearch(request.getSearch());

        return new FolderListQuery(
                page,
                size,
                normalizedSearch,
                request.getParentFolderId(),
                resolvedSortField,
                resolvedSortDirection);
    }

    private static String normalizeSearch(String search) {
        if (search == null) {
            return "";
        }

        final var normalized = search.trim();
        if (normalized.isEmpty()) {
            return "";
        }
        return normalized;
    }
}


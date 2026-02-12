package com.learn.wire.dto.deck.query;

import com.learn.wire.constant.DeckConst;
import com.learn.wire.constant.ErrorMessageConst;
import com.learn.wire.dto.common.query.SortDirection;
import com.learn.wire.dto.deck.request.DeckListRequest;
import com.learn.wire.exception.BadRequestException;

public record DeckListQuery(
        Long folderId,
        int page,
        int size,
        String search,
        DeckSortField sortField,
        SortDirection sortDirection) {

    public static DeckListQuery fromRequest(Long folderId, DeckListRequest request) {
        if (request == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }
        if (folderId == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }

        final int page = request.getPage();
        if (page < DeckConst.MIN_PAGE) {
            throw new BadRequestException(DeckConst.PAGE_INVALID_KEY);
        }

        final int size = request.getSize();
        if ((size < DeckConst.MIN_SIZE) || (size > DeckConst.MAX_SIZE)) {
            throw new BadRequestException(DeckConst.SIZE_INVALID_KEY);
        }

        final DeckSortField sortField = DeckSortField.fromValue(request.getSortBy());
        final SortDirection sortDirection = SortDirection.fromRaw(
                request.getSortDirection(),
                DeckConst.SORT_DIRECTION_INVALID_KEY);
        final String search = normalizeSearch(request.getSearch());
        return new DeckListQuery(
                folderId,
                page,
                size,
                search,
                sortField,
                sortDirection);
    }

    private static String normalizeSearch(String value) {
        if (value == null) {
            return "";
        }
        final String normalized = value.trim();
        if (normalized.isEmpty()) {
            return "";
        }
        return normalized;
    }
}

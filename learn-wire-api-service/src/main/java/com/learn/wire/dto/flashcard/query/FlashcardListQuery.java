package com.learn.wire.dto.flashcard.query;

import com.learn.wire.constant.ErrorMessageConst;
import com.learn.wire.constant.FlashcardConst;
import com.learn.wire.dto.common.query.SortDirection;
import com.learn.wire.dto.flashcard.request.FlashcardListRequest;
import com.learn.wire.exception.BadRequestException;

public record FlashcardListQuery(
        Long folderId,
        int page,
        int size,
        String search,
        FlashcardSortField sortField,
        SortDirection sortDirection) {

    public static FlashcardListQuery fromRequest(Long folderId, FlashcardListRequest request) {
        if (request == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }
        if (folderId == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }

        final int page = request.getPage();
        if (page < FlashcardConst.MIN_PAGE) {
            throw new BadRequestException(FlashcardConst.PAGE_INVALID_KEY);
        }

        final int size = request.getSize();
        if ((size < FlashcardConst.MIN_SIZE) || (size > FlashcardConst.MAX_SIZE)) {
            throw new BadRequestException(FlashcardConst.SIZE_INVALID_KEY);
        }

        final FlashcardSortField sortField = FlashcardSortField.fromValue(request.getSortBy());
        final SortDirection sortDirection = SortDirection.fromRaw(
                request.getSortDirection(),
                FlashcardConst.SORT_DIRECTION_INVALID_KEY);
        final String search = normalizeSearch(request.getSearch());
        return new FlashcardListQuery(
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

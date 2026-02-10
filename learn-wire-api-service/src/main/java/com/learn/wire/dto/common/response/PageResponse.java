package com.learn.wire.dto.common.response;

import java.util.List;

public record PageResponse<T>(
        List<T> items,
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean hasNext,
        boolean hasPrevious,
        String search,
        String sortBy,
        String sortDirection) {
}

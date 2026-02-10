package com.learn.wire.dto.folder.query;

import java.util.List;

import com.learn.wire.constant.FolderConst;
import com.learn.wire.dto.common.query.SortFieldResolver;
import com.learn.wire.dto.common.query.SortFieldResolver.SortFieldResolveSpec;
import com.learn.wire.dto.common.query.SortableField;

public enum FolderSortField implements SortableField {
    CREATED_AT(FolderConst.SORT_BY_CREATED_AT, "createdAt"),
    NAME(FolderConst.SORT_BY_NAME, "name"),
    FLASHCARD_COUNT(FolderConst.SORT_BY_FLASHCARD_COUNT, "aggregateFlashcardCount");

    private static final SortFieldResolveSpec<FolderSortField> RESOLVE_SPEC = new SortFieldResolveSpec<>(
            CREATED_AT,
            List.of(values()),
            FolderConst.SORT_BY_INVALID_KEY);

    private final String apiValue;
    private final String entitySortProperty;

    FolderSortField(String apiValue, String entitySortProperty) {
        this.apiValue = apiValue;
        this.entitySortProperty = entitySortProperty;
    }

    public String value() {
        return this.apiValue;
    }

    public String sortProperty() {
        return this.entitySortProperty;
    }

    public static FolderSortField fromValue(String rawValue) {
        return SortFieldResolver.fromRaw(rawValue, RESOLVE_SPEC);
    }
}

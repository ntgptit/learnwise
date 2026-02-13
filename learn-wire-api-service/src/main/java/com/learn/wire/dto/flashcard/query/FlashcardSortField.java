package com.learn.wire.dto.flashcard.query;

import java.util.List;

import com.learn.wire.constant.FlashcardConst;
import com.learn.wire.dto.common.query.SortFieldResolver;
import com.learn.wire.dto.common.query.SortFieldResolver.SortFieldResolveSpec;
import com.learn.wire.dto.common.query.SortableField;

public enum FlashcardSortField implements SortableField {
    CREATED_AT(FlashcardConst.SORT_BY_CREATED_AT, "createdAt"),
    UPDATED_AT(FlashcardConst.SORT_BY_UPDATED_AT, "updatedAt"),
    FRONT_TEXT(FlashcardConst.SORT_BY_FRONT_TEXT, "frontText");

    private static final SortFieldResolveSpec<FlashcardSortField> RESOLVE_SPEC = new SortFieldResolveSpec<>(
            CREATED_AT,
            List.of(values()),
            FlashcardConst.SORT_BY_INVALID_KEY);

    private final String apiValue;
    private final String entitySortProperty;

    FlashcardSortField(String apiValue, String entitySortProperty) {
        this.apiValue = apiValue;
        this.entitySortProperty = entitySortProperty;
    }

    public String value() {
        return this.apiValue;
    }

    public String sortProperty() {
        return this.entitySortProperty;
    }

    public static FlashcardSortField fromValue(String rawValue) {
        return SortFieldResolver.fromRaw(rawValue, RESOLVE_SPEC);
    }
}

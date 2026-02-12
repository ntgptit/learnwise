package com.learn.wire.dto.deck.query;

import java.util.List;

import com.learn.wire.constant.DeckConst;
import com.learn.wire.dto.common.query.SortFieldResolver;
import com.learn.wire.dto.common.query.SortFieldResolver.SortFieldResolveSpec;
import com.learn.wire.dto.common.query.SortableField;

public enum DeckSortField implements SortableField {
    CREATED_AT(DeckConst.SORT_BY_CREATED_AT, "createdAt"),
    NAME(DeckConst.SORT_BY_NAME, "name");

    private static final SortFieldResolveSpec<DeckSortField> RESOLVE_SPEC = new SortFieldResolveSpec<>(
            CREATED_AT,
            List.of(values()),
            DeckConst.SORT_BY_INVALID_KEY);

    private final String apiValue;
    private final String entitySortProperty;

    DeckSortField(String apiValue, String entitySortProperty) {
        this.apiValue = apiValue;
        this.entitySortProperty = entitySortProperty;
    }

    public String value() {
        return this.apiValue;
    }

    public String sortProperty() {
        return this.entitySortProperty;
    }

    public static DeckSortField fromValue(String rawValue) {
        return SortFieldResolver.fromRaw(rawValue, RESOLVE_SPEC);
    }
}

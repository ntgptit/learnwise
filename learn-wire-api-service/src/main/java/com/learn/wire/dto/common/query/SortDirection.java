package com.learn.wire.dto.common.query;

import org.springframework.data.domain.Sort;

import com.learn.wire.exception.BadRequestException;

public enum SortDirection {
    ASC("asc", Sort.Direction.ASC),
    DESC("desc", Sort.Direction.DESC);

    private final String value;
    private final Sort.Direction springDirection;

    SortDirection(String value, Sort.Direction springDirection) {
        this.value = value;
        this.springDirection = springDirection;
    }

    public String value() {
        return this.value;
    }

    public Sort.Direction toSpringDirection() {
        return this.springDirection;
    }

    public boolean isDescending() {
        return this == DESC;
    }

    public static SortDirection fromRaw(String rawValue, String invalidMessageKey) {
        final String normalizedValue = rawValue == null
                ? DESC.value
                : rawValue.trim();

        for (final SortDirection candidate : values()) {
            if (candidate.value.equalsIgnoreCase(normalizedValue)) {
                return candidate;
            }
        }
        throw new BadRequestException(invalidMessageKey);
    }
}

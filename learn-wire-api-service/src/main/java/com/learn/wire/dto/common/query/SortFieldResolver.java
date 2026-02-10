package com.learn.wire.dto.common.query;

import java.util.List;

import com.learn.wire.exception.BadRequestException;

public final class SortFieldResolver {

    private SortFieldResolver() {
    }

    public static <T extends Enum<T> & SortableField> T fromRaw(
            String rawValue,
            SortFieldResolveSpec<T> resolveSpec) {
        final String normalizedValue = rawValue == null
                ? resolveSpec.defaultValue().value()
                : rawValue.trim();

        for (final T candidate : resolveSpec.candidates()) {
            if (candidate.value().equalsIgnoreCase(normalizedValue)) {
                return candidate;
            }
        }
        throw new BadRequestException(resolveSpec.invalidMessageKey());
    }

    public record SortFieldResolveSpec<T extends Enum<T> & SortableField>(
            T defaultValue,
            List<T> candidates,
            String invalidMessageKey) {
    }
}

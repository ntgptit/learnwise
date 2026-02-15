package com.learn.wire.dto.study.query;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.exception.BadRequestException;

public enum StudyMode {
    REVIEW(StudyConst.MODE_REVIEW),
    MATCH(StudyConst.MODE_MATCH),
    GUESS(StudyConst.MODE_GUESS),
    RECALL(StudyConst.MODE_RECALL),
    FILL(StudyConst.MODE_FILL);

    private final String value;

    StudyMode(String value) {
        this.value = value;
    }

    public String value() {
        return this.value;
    }

    public static StudyMode fromValue(String rawValue) {
        final String normalized = rawValue == null
                ? ""
                : rawValue.trim();
        for (final StudyMode candidate : values()) {
            if (candidate.value.equalsIgnoreCase(normalized)) {
                return candidate;
            }
        }
        throw new BadRequestException(StudyConst.MODE_INVALID_KEY);
    }
}

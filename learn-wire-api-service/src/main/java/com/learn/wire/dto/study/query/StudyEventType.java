package com.learn.wire.dto.study.query;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.exception.BadRequestException;

public enum StudyEventType {
    REVIEW_NEXT(StudyConst.EVENT_REVIEW_NEXT),
    REVIEW_PREVIOUS(StudyConst.EVENT_REVIEW_PREVIOUS),
    REVIEW_GOTO_INDEX(StudyConst.EVENT_REVIEW_GOTO_INDEX),
    MATCH_SELECT_LEFT(StudyConst.EVENT_MATCH_SELECT_LEFT),
    MATCH_SELECT_RIGHT(StudyConst.EVENT_MATCH_SELECT_RIGHT);

    private final String value;

    StudyEventType(String value) {
        this.value = value;
    }

    public String value() {
        return this.value;
    }

    public boolean isLinearNavigation() {
        if (this == REVIEW_NEXT) {
            return true;
        }
        if (this == REVIEW_PREVIOUS) {
            return true;
        }
        return this == REVIEW_GOTO_INDEX;
    }

    public boolean isMatchSelection() {
        if (this == MATCH_SELECT_LEFT) {
            return true;
        }
        return this == MATCH_SELECT_RIGHT;
    }

    public static StudyEventType fromValue(String rawValue) {
        final String normalized = rawValue == null
                ? ""
                : rawValue.trim();
        for (final StudyEventType candidate : values()) {
            if (candidate.value.equalsIgnoreCase(normalized)) {
                return candidate;
            }
        }
        throw new BadRequestException(StudyConst.EVENT_TYPE_INVALID_KEY);
    }
}

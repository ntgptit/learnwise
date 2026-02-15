package com.learn.wire.dto.study.query;

import org.apache.commons.lang3.StringUtils;

import com.learn.wire.constant.ErrorMessageConst;
import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.request.StudySessionEventRequest;
import com.learn.wire.exception.BadRequestException;

public record StudySessionEventCommand(
        String clientEventId,
        int clientSequence,
        StudyEventType eventType,
        Long targetTileId,
        Integer targetIndex) {

    public static StudySessionEventCommand fromRequest(StudySessionEventRequest request) {
        if (request == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }
        final String clientEventId = normalizeClientEventId(request.clientEventId());
        final int clientSequence = resolveClientSequence(request.clientSequence());
        final StudyEventType eventType = StudyEventType.fromValue(request.eventType());
        return new StudySessionEventCommand(
                clientEventId,
                clientSequence,
                eventType,
                request.targetTileId(),
                request.targetIndex());
    }

    private static String normalizeClientEventId(String rawValue) {
        final String normalized = StringUtils.trimToEmpty(rawValue);
        if (!normalized.isEmpty()) {
            return normalized;
        }
        throw new BadRequestException(StudyConst.EVENT_CLIENT_EVENT_ID_REQUIRED_KEY);
    }

    private static int resolveClientSequence(Integer rawValue) {
        if (rawValue == null) {
            throw new BadRequestException(StudyConst.EVENT_CLIENT_SEQUENCE_INVALID_KEY);
        }
        if (rawValue >= StudyConst.DEFAULT_CLIENT_SEQUENCE) {
            return rawValue;
        }
        throw new BadRequestException(StudyConst.EVENT_CLIENT_SEQUENCE_INVALID_KEY);
    }
}

package com.learn.wire.dto.study.query;

import com.learn.wire.constant.ErrorMessageConst;
import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.request.StudySessionStartRequest;
import com.learn.wire.exception.BadRequestException;

public record StudySessionStartCommand(
        Long deckId,
        StudyMode mode,
        int seed) {

    public static StudySessionStartCommand fromRequest(Long deckId, StudySessionStartRequest request) {
        if (request == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }
        if (deckId == null) {
            throw new BadRequestException(ErrorMessageConst.COMMON_ERROR_INVALID_REQUEST);
        }
        final StudyMode mode = StudyMode.fromValue(request.mode());
        final int seed = resolveSeed(request.seed());
        return new StudySessionStartCommand(deckId, mode, seed);
    }

    private static int resolveSeed(Integer seed) {
        if (seed == null) {
            return StudyConst.DEFAULT_SEED;
        }
        if (seed >= StudyConst.MIN_SEED) {
            return seed;
        }
        throw new BadRequestException(StudyConst.SEED_INVALID_KEY);
    }
}

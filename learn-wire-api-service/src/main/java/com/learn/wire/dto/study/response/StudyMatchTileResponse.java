package com.learn.wire.dto.study.response;

public record StudyMatchTileResponse(
        Long tileId,
        int pairKey,
        String side,
        String label,
        int tileOrder,
        boolean matched,
        boolean hidden,
        boolean selected,
        boolean successFlash,
        boolean errorFlash) {
}

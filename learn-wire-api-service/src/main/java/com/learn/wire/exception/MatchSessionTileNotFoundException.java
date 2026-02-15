package com.learn.wire.exception;

import com.learn.wire.constant.StudyConst;

public class MatchSessionTileNotFoundException extends ResourceNotFoundException {

    private static final long serialVersionUID = 1L;

    public MatchSessionTileNotFoundException(Long tileId) {
        super(StudyConst.MATCH_TILE_NOT_FOUND_KEY, tileId);
    }
}

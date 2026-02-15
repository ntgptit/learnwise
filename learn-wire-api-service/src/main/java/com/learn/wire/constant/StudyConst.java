package com.learn.wire.constant;

public final class StudyConst {

    private StudyConst() {
    }

    public static final String SESSION_TABLE_NAME = "study_sessions";
    public static final String SESSION_ITEM_TABLE_NAME = "study_session_items";
    public static final String ATTEMPT_TABLE_NAME = "study_attempts";
    public static final String MATCH_TILE_TABLE_NAME = "match_session_tiles";
    public static final String MATCH_STATE_TABLE_NAME = "match_session_states";
    public static final int MODE_MAX_LENGTH = 20;
    public static final int STATUS_MAX_LENGTH = 20;
    public static final int EVENT_TYPE_MAX_LENGTH = 80;
    public static final int EVENT_ID_MAX_LENGTH = 120;
    public static final int TILE_SIDE_MAX_LENGTH = 10;
    public static final int FEEDBACK_STATUS_MAX_LENGTH = 20;

    public static final String DEFAULT_ACTOR = "system";
    public static final int DEFAULT_SEED = 37;
    public static final int MIN_SEED = 0;
    public static final int DEFAULT_INDEX = 0;
    public static final int DEFAULT_CLIENT_SEQUENCE = 0;
    public static final int MINIMUM_MATCH_PAIR_COUNT = 2;
    public static final long MATCH_FEEDBACK_HOLD_MILLIS = 2250L;
    public static final int ZERO_SCORE = 0;
    public static final String ENGINE_NOT_REGISTERED_ERROR = "Study mode engine is not registered: ";
    public static final String ENGINE_DUPLICATED_ERROR = "Duplicate study mode engine registration: ";

    public static final String MODE_REVIEW = "review";
    public static final String MODE_MATCH = "match";
    public static final String MODE_GUESS = "guess";
    public static final String MODE_RECALL = "recall";
    public static final String MODE_FILL = "fill";

    public static final String SESSION_STATUS_ACTIVE = "ACTIVE";
    public static final String SESSION_STATUS_COMPLETED = "COMPLETED";

    public static final String TILE_SIDE_LEFT = "LEFT";
    public static final String TILE_SIDE_RIGHT = "RIGHT";
    public static final String FEEDBACK_SUCCESS = "SUCCESS";
    public static final String FEEDBACK_ERROR = "ERROR";

    public static final String EVENT_REVIEW_NEXT = "review.next";
    public static final String EVENT_REVIEW_PREVIOUS = "review.previous";
    public static final String EVENT_REVIEW_GOTO_INDEX = "review.gotoIndex";
    public static final String EVENT_MATCH_SELECT_LEFT = "match.selectLeft";
    public static final String EVENT_MATCH_SELECT_RIGHT = "match.selectRight";

    public static final String SESSION_NOT_FOUND_KEY = ErrorMessageConst.STUDY_ERROR_SESSION_NOT_FOUND;
    public static final String SESSION_NOT_ACTIVE_KEY = ErrorMessageConst.STUDY_ERROR_SESSION_NOT_ACTIVE;
    public static final String MATCH_STATE_NOT_FOUND_KEY = ErrorMessageConst.STUDY_ERROR_MATCH_STATE_NOT_FOUND;
    public static final String MATCH_TILE_NOT_FOUND_KEY = ErrorMessageConst.STUDY_ERROR_MATCH_TILE_NOT_FOUND;
    public static final String MATCH_TILE_SIDE_INVALID_KEY = ErrorMessageConst.STUDY_ERROR_MATCH_TILE_SIDE_INVALID;
    public static final String DECK_HAS_NO_FLASHCARDS_KEY = ErrorMessageConst.STUDY_ERROR_DECK_HAS_NO_FLASHCARDS;
    public static final String MATCH_REQUIRES_MORE_FLASHCARDS_KEY = ErrorMessageConst.STUDY_ERROR_MATCH_REQUIRES_MORE_FLASHCARDS;
    public static final String EVENT_NOT_SUPPORTED_KEY = ErrorMessageConst.STUDY_ERROR_EVENT_NOT_SUPPORTED;

    public static final String MODE_INVALID_KEY = ErrorMessageConst.STUDY_VALIDATION_MODE_INVALID;
    public static final String SEED_INVALID_KEY = ErrorMessageConst.STUDY_VALIDATION_SEED_INVALID;
    public static final String EVENT_TYPE_INVALID_KEY = ErrorMessageConst.STUDY_VALIDATION_EVENT_TYPE_INVALID;
    public static final String EVENT_CLIENT_EVENT_ID_REQUIRED_KEY = ErrorMessageConst.STUDY_VALIDATION_EVENT_CLIENT_EVENT_ID_REQUIRED;
    public static final String EVENT_CLIENT_SEQUENCE_INVALID_KEY = ErrorMessageConst.STUDY_VALIDATION_EVENT_CLIENT_SEQUENCE_INVALID;
    public static final String EVENT_TARGET_TILE_REQUIRED_KEY = ErrorMessageConst.STUDY_VALIDATION_EVENT_TARGET_TILE_REQUIRED;
    public static final String EVENT_TARGET_INDEX_INVALID_KEY = ErrorMessageConst.STUDY_VALIDATION_EVENT_TARGET_INDEX_INVALID;
}

package com.learn.wire.constant;

public final class FolderConst {

    private FolderConst() {
    }

    public static final String TABLE_NAME = "folders";

    public static final int NAME_MIN_LENGTH = 1;
    public static final int NAME_MAX_LENGTH = 120;
    public static final int DESCRIPTION_MAX_LENGTH = 400;
    public static final int COLOR_HEX_MAX_LENGTH = 16;
    public static final int DEFAULT_PAGE = 0;
    public static final int DEFAULT_SIZE = 20;
    public static final int MIN_PAGE = 0;
    public static final int MIN_SIZE = 1;
    public static final int MAX_SIZE = 100;
    public static final String DEFAULT_PAGE_PARAM = "0";
    public static final String DEFAULT_SIZE_PARAM = "20";

    public static final String DEFAULT_COLOR_HEX = "#4F46E5";
    public static final String DEFAULT_ACTOR = "system";
    public static final String COLOR_HEX_PATTERN = "^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$";
    public static final String SORT_BY_CREATED_AT = "createdAt";
    public static final String SORT_BY_NAME = "name";
    public static final String SORT_BY_FLASHCARD_COUNT = "flashcardCount";
    public static final String SORT_BY_TIE_BREAKER = "id";
    public static final String SORT_DIRECTION_ASC = "asc";
    public static final String SORT_DIRECTION_DESC = "desc";
    public static final int DEFAULT_DIRECT_FLASHCARD_COUNT = 0;

    public static final String NAME_IS_REQUIRED_KEY = ErrorMessageConst.FOLDER_VALIDATION_NAME_REQUIRED;
    public static final String NAME_TOO_LONG_KEY = ErrorMessageConst.FOLDER_VALIDATION_NAME_TOO_LONG;
    public static final String DESCRIPTION_TOO_LONG_KEY = ErrorMessageConst.FOLDER_VALIDATION_DESCRIPTION_TOO_LONG;
    public static final String COLOR_HEX_INVALID_KEY = ErrorMessageConst.FOLDER_VALIDATION_COLOR_INVALID;
    public static final String PAGE_INVALID_KEY = ErrorMessageConst.FOLDER_VALIDATION_PAGE_INVALID;
    public static final String SIZE_INVALID_KEY = ErrorMessageConst.FOLDER_VALIDATION_SIZE_INVALID;
    public static final String SORT_BY_INVALID_KEY = ErrorMessageConst.FOLDER_VALIDATION_SORT_BY_INVALID;
    public static final String SORT_DIRECTION_INVALID_KEY = ErrorMessageConst.FOLDER_VALIDATION_SORT_DIRECTION_INVALID;
    public static final String PARENT_NOT_FOUND_KEY = ErrorMessageConst.FOLDER_VALIDATION_PARENT_NOT_FOUND;
    public static final String PARENT_SELF_KEY = ErrorMessageConst.FOLDER_VALIDATION_PARENT_SELF;
    public static final String PARENT_CYCLE_KEY = ErrorMessageConst.FOLDER_VALIDATION_PARENT_CYCLE;
    public static final String NEGATIVE_AGGREGATE_KEY = ErrorMessageConst.FOLDER_ERROR_NEGATIVE_AGGREGATE;
    public static final String DUPLICATE_NAME_KEY = ErrorMessageConst.FOLDER_ERROR_DUPLICATE_NAME;
    public static final String PARENT_HAS_DECKS_KEY = ErrorMessageConst.FOLDER_ERROR_PARENT_HAS_DECKS;

    public static final String NAME_IS_REQUIRED_MESSAGE = "{" + NAME_IS_REQUIRED_KEY + "}";
    public static final String NAME_TOO_LONG_MESSAGE = "{" + NAME_TOO_LONG_KEY + "}";
    public static final String DESCRIPTION_TOO_LONG_MESSAGE = "{" + DESCRIPTION_TOO_LONG_KEY + "}";
    public static final String COLOR_HEX_INVALID_MESSAGE = "{" + COLOR_HEX_INVALID_KEY + "}";
}

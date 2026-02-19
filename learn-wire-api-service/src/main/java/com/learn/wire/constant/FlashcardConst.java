package com.learn.wire.constant;

public final class FlashcardConst {

    private FlashcardConst() {
    }

    public static final String TABLE_NAME = "flashcards";
    public static final int FRONT_TEXT_MIN_LENGTH = 1;
    public static final int FRONT_TEXT_MAX_LENGTH = 300;
    public static final int BACK_TEXT_MIN_LENGTH = 1;
    public static final int BACK_TEXT_MAX_LENGTH = 2000;
    public static final int DEFAULT_PAGE = 0;
    public static final int DEFAULT_SIZE = 20;
    public static final int MIN_PAGE = 0;
    public static final int MIN_SIZE = 1;
    public static final int MAX_SIZE = 100;
    public static final String DEFAULT_PAGE_PARAM = "0";
    public static final String DEFAULT_SIZE_PARAM = "20";
    public static final String SORT_BY_CREATED_AT = "createdAt";
    public static final String SORT_BY_UPDATED_AT = "updatedAt";
    public static final String SORT_BY_FRONT_TEXT = "frontText";
    public static final String SORT_BY_TIE_BREAKER = "id";
    public static final String SORT_DIRECTION_ASC = "asc";
    public static final String SORT_DIRECTION_DESC = "desc";
    public static final String DEFAULT_ACTOR = "system";

    public static final String FRONT_REQUIRED_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_FRONT_REQUIRED;
    public static final String FRONT_TOO_LONG_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_FRONT_TOO_LONG;
    public static final String BACK_REQUIRED_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_BACK_REQUIRED;
    public static final String BACK_TOO_LONG_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_BACK_TOO_LONG;
    public static final String PAGE_INVALID_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_PAGE_INVALID;
    public static final String SIZE_INVALID_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_SIZE_INVALID;
    public static final String SORT_BY_INVALID_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_SORT_BY_INVALID;
    public static final String SORT_DIRECTION_INVALID_KEY = ErrorMessageConst.FLASHCARD_VALIDATION_SORT_DIRECTION_INVALID;
    public static final String NOT_FOUND_KEY = ErrorMessageConst.FLASHCARD_ERROR_NOT_FOUND;
    public static final String DECK_NOT_FOUND_KEY = ErrorMessageConst.FLASHCARD_ERROR_DECK_NOT_FOUND;
    public static final String TERM_LANG_MISMATCH_KEY = ErrorMessageConst.FLASHCARD_ERROR_TERM_LANG_MISMATCH;

    public static final String FRONT_REQUIRED_MESSAGE = "{" + FRONT_REQUIRED_KEY + "}";
    public static final String FRONT_TOO_LONG_MESSAGE = "{" + FRONT_TOO_LONG_KEY + "}";
    public static final String BACK_REQUIRED_MESSAGE = "{" + BACK_REQUIRED_KEY + "}";
    public static final String BACK_TOO_LONG_MESSAGE = "{" + BACK_TOO_LONG_KEY + "}";
}

package com.learn.wire.constant;

public final class ErrorMessageConst {

    private ErrorMessageConst() {
    }

    public static final String COMMON_ERROR_INVALID_REQUEST = "common.error.invalidRequest";
    public static final String COMMON_ERROR_INTERNAL = "common.error.internal";
    public static final String COMMON_ERROR_RUNTIME = "common.error.runtime";
    public static final String FOLDER_ERROR_NOT_FOUND = "folder.error.notFound";
    public static final String FOLDER_ERROR_NEGATIVE_AGGREGATE = "folder.error.negativeAggregate";
    public static final String FOLDER_ERROR_DUPLICATE_NAME = "folder.error.duplicateName";
    public static final String FOLDER_ERROR_PARENT_HAS_DECKS = "folder.error.parentHasDecks";
    public static final String DECK_ERROR_NOT_FOUND = "deck.error.notFound";
    public static final String DECK_ERROR_DUPLICATE_NAME = "deck.error.duplicateName";
    public static final String DECK_ERROR_FOLDER_HAS_SUBFOLDERS = "deck.error.folderHasSubfolders";
    public static final String FLASHCARD_ERROR_NOT_FOUND = "flashcard.error.notFound";
    public static final String FLASHCARD_ERROR_DECK_NOT_FOUND = "flashcard.error.deckNotFound";
    public static final String AUTH_ERROR_EMAIL_ALREADY_EXISTS = "auth.error.emailAlreadyExists";
    public static final String AUTH_ERROR_INVALID_CREDENTIALS = "auth.error.invalidCredentials";
    public static final String AUTH_ERROR_REFRESH_TOKEN_INVALID = "auth.error.refreshTokenInvalid";
    public static final String AUTH_ERROR_UNAUTHORIZED = "auth.error.unauthorized";
    public static final String STUDY_ERROR_SESSION_NOT_FOUND = "study.error.sessionNotFound";
    public static final String STUDY_ERROR_SESSION_NOT_ACTIVE = "study.error.sessionNotActive";
    public static final String STUDY_ERROR_MATCH_STATE_NOT_FOUND = "study.error.matchStateNotFound";
    public static final String STUDY_ERROR_MATCH_TILE_NOT_FOUND = "study.error.matchTileNotFound";
    public static final String STUDY_ERROR_MATCH_TILE_SIDE_INVALID = "study.error.matchTileSideInvalid";
    public static final String STUDY_ERROR_DECK_HAS_NO_FLASHCARDS = "study.error.deckHasNoFlashcards";
    public static final String STUDY_ERROR_MATCH_REQUIRES_MORE_FLASHCARDS = "study.error.matchRequiresMoreFlashcards";
    public static final String STUDY_ERROR_EVENT_NOT_SUPPORTED = "study.error.eventNotSupported";

    public static final String FOLDER_VALIDATION_NAME_REQUIRED = "folder.validation.name.required";
    public static final String FOLDER_VALIDATION_NAME_TOO_LONG = "folder.validation.name.tooLong";
    public static final String FOLDER_VALIDATION_DESCRIPTION_TOO_LONG = "folder.validation.description.tooLong";
    public static final String FOLDER_VALIDATION_COLOR_INVALID = "folder.validation.color.invalid";
    public static final String FOLDER_VALIDATION_PAGE_INVALID = "folder.validation.page.invalid";
    public static final String FOLDER_VALIDATION_SIZE_INVALID = "folder.validation.size.invalid";
    public static final String FOLDER_VALIDATION_SORT_BY_INVALID = "folder.validation.sortBy.invalid";
    public static final String FOLDER_VALIDATION_SORT_DIRECTION_INVALID = "folder.validation.sortDirection.invalid";
    public static final String FOLDER_VALIDATION_PARENT_NOT_FOUND = "folder.validation.parent.notFound";
    public static final String FOLDER_VALIDATION_PARENT_SELF = "folder.validation.parent.self";
    public static final String FOLDER_VALIDATION_PARENT_CYCLE = "folder.validation.parent.cycle";
    public static final String FLASHCARD_VALIDATION_FRONT_REQUIRED = "flashcard.validation.front.required";
    public static final String FLASHCARD_VALIDATION_FRONT_TOO_LONG = "flashcard.validation.front.tooLong";
    public static final String FLASHCARD_VALIDATION_BACK_REQUIRED = "flashcard.validation.back.required";
    public static final String FLASHCARD_VALIDATION_BACK_TOO_LONG = "flashcard.validation.back.tooLong";
    public static final String FLASHCARD_VALIDATION_PAGE_INVALID = "flashcard.validation.page.invalid";
    public static final String FLASHCARD_VALIDATION_SIZE_INVALID = "flashcard.validation.size.invalid";
    public static final String FLASHCARD_VALIDATION_SORT_BY_INVALID = "flashcard.validation.sortBy.invalid";
    public static final String FLASHCARD_VALIDATION_SORT_DIRECTION_INVALID = "flashcard.validation.sortDirection.invalid";
    public static final String DECK_VALIDATION_NAME_REQUIRED = "deck.validation.name.required";
    public static final String DECK_VALIDATION_NAME_TOO_LONG = "deck.validation.name.tooLong";
    public static final String DECK_VALIDATION_DESCRIPTION_TOO_LONG = "deck.validation.description.tooLong";
    public static final String DECK_VALIDATION_PAGE_INVALID = "deck.validation.page.invalid";
    public static final String DECK_VALIDATION_SIZE_INVALID = "deck.validation.size.invalid";
    public static final String DECK_VALIDATION_SORT_BY_INVALID = "deck.validation.sortBy.invalid";
    public static final String DECK_VALIDATION_SORT_DIRECTION_INVALID = "deck.validation.sortDirection.invalid";
    public static final String AUTH_VALIDATION_EMAIL_REQUIRED = "auth.validation.email.required";
    public static final String AUTH_VALIDATION_EMAIL_INVALID = "auth.validation.email.invalid";
    public static final String AUTH_VALIDATION_EMAIL_TOO_LONG = "auth.validation.email.tooLong";
    public static final String AUTH_VALIDATION_PASSWORD_REQUIRED = "auth.validation.password.required";
    public static final String AUTH_VALIDATION_PASSWORD_TOO_SHORT = "auth.validation.password.tooShort";
    public static final String AUTH_VALIDATION_PASSWORD_TOO_LONG = "auth.validation.password.tooLong";
    public static final String AUTH_VALIDATION_DISPLAY_NAME_REQUIRED = "auth.validation.displayName.required";
    public static final String AUTH_VALIDATION_DISPLAY_NAME_TOO_LONG = "auth.validation.displayName.tooLong";
    public static final String AUTH_VALIDATION_REFRESH_TOKEN_REQUIRED = "auth.validation.refreshToken.required";
    public static final String AUTH_VALIDATION_THEME_MODE_REQUIRED = "auth.validation.themeMode.required";
    public static final String AUTH_VALIDATION_THEME_MODE_INVALID = "auth.validation.themeMode.invalid";
    public static final String AUTH_VALIDATION_STUDY_AUTO_PLAY_AUDIO_REQUIRED = "auth.validation.study.autoPlayAudio.required";
    public static final String AUTH_VALIDATION_STUDY_CARDS_PER_SESSION_REQUIRED = "auth.validation.study.cardsPerSession.required";
    public static final String AUTH_VALIDATION_STUDY_CARDS_PER_SESSION_MIN = "auth.validation.study.cardsPerSession.min";
    public static final String AUTH_VALIDATION_STUDY_CARDS_PER_SESSION_MAX = "auth.validation.study.cardsPerSession.max";
    public static final String STUDY_VALIDATION_MODE_INVALID = "study.validation.mode.invalid";
    public static final String STUDY_VALIDATION_SEED_INVALID = "study.validation.seed.invalid";
    public static final String STUDY_VALIDATION_EVENT_TYPE_INVALID = "study.validation.eventType.invalid";
    public static final String STUDY_VALIDATION_EVENT_CLIENT_EVENT_ID_REQUIRED = "study.validation.event.clientEventId.required";
    public static final String STUDY_VALIDATION_EVENT_CLIENT_SEQUENCE_INVALID = "study.validation.event.clientSequence.invalid";
    public static final String STUDY_VALIDATION_EVENT_TARGET_TILE_REQUIRED = "study.validation.event.targetTileId.required";
    public static final String STUDY_VALIDATION_EVENT_TARGET_INDEX_INVALID = "study.validation.event.targetIndex.invalid";
}

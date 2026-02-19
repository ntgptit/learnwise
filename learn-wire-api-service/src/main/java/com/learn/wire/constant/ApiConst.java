package com.learn.wire.constant;

public final class ApiConst {

    private ApiConst() {
    }

    public static final String API_BASE_PATH = "/v1";
    public static final String FOLDERS_PATH = API_BASE_PATH + "/folders";
    public static final String FOLDERS_WILDCARD_PATH = FOLDERS_PATH + "/**";
    public static final String DECKS_PATH = FOLDERS_PATH + "/{folderId}/decks";
    public static final String DECKS_WILDCARD_PATH = API_BASE_PATH + "/folders/*/decks/**";
    public static final String DECKS_ROOT_WILDCARD_PATH = API_BASE_PATH + "/folders/*/decks";
    public static final String DECK_FLASHCARDS_PATH = API_BASE_PATH + "/decks/{deckId}/flashcards";
    public static final String DECK_FLASHCARDS_WILDCARD_PATH = API_BASE_PATH + "/decks/*/flashcards/**";
    public static final String DECK_FLASHCARDS_ROOT_WILDCARD_PATH = API_BASE_PATH + "/decks/*/flashcards";
    public static final String STUDY_SESSIONS_PATH = API_BASE_PATH + "/decks/{deckId}/study-sessions";
    public static final String STUDY_SESSIONS_WILDCARD_PATH = API_BASE_PATH + "/decks/*/study-sessions/**";
    public static final String STUDY_SESSIONS_ROOT_WILDCARD_PATH = API_BASE_PATH + "/decks/*/study-sessions";
    public static final String STUDY_SESSION_PATH = API_BASE_PATH + "/study-sessions";
    public static final String STUDY_SESSION_BY_ID_PATH = STUDY_SESSION_PATH + "/{sessionId}";
    public static final String STUDY_SESSION_EVENTS_PATH = STUDY_SESSION_BY_ID_PATH + "/events";
    public static final String STUDY_SESSION_COMPLETE_PATH = STUDY_SESSION_BY_ID_PATH + "/complete";
    public static final String STUDY_SESSION_WILDCARD_PATH = STUDY_SESSION_PATH + "/**";
    public static final String STUDY_SESSION_ROOT_WILDCARD_PATH = STUDY_SESSION_PATH;
    public static final String AUTH_PATH = API_BASE_PATH + "/auth";
    public static final String AUTH_REGISTER_SUB_PATH = "/register";
    public static final String AUTH_LOGIN_SUB_PATH = "/login";
    public static final String AUTH_REFRESH_SUB_PATH = "/refresh";
    public static final String AUTH_ME_SUB_PATH = "/me";
    public static final String AUTH_ME_SETTINGS_SUB_PATH = "/me/settings";
    public static final String FOLDER_ID_SUB_PATH = "/{folderId}";
    public static final String DECK_ID_SUB_PATH = "/{deckId}";
    public static final String FLASHCARD_ID_SUB_PATH = "/{flashcardId}";
    public static final String AUTH_REGISTER_PATH = AUTH_PATH + AUTH_REGISTER_SUB_PATH;
    public static final String AUTH_LOGIN_PATH = AUTH_PATH + AUTH_LOGIN_SUB_PATH;
    public static final String AUTH_REFRESH_PATH = AUTH_PATH + AUTH_REFRESH_SUB_PATH;
    public static final String AUTH_ME_PATH = AUTH_PATH + AUTH_ME_SUB_PATH;
    public static final String AUTH_ME_SETTINGS_PATH = AUTH_PATH + AUTH_ME_SETTINGS_SUB_PATH;
    public static final String AUTH_WILDCARD_PATH = AUTH_PATH + "/**";
    public static final String LANGUAGES_PATH = API_BASE_PATH + "/languages";
    public static final String OPEN_API_TITLE = "Learn Wire API";
    public static final String OPEN_API_VERSION = "v1";
    public static final String OPEN_API_DESCRIPTION = "REST API for Learn Wire backend services.";

    public static final String ERROR_CODE_BAD_REQUEST = "BAD_REQUEST";
    public static final String ERROR_CODE_VALIDATION = "VALIDATION_ERROR";
    public static final String ERROR_CODE_FOLDER_NOT_FOUND = "FOLDER_NOT_FOUND";
    public static final String ERROR_CODE_DECK_NOT_FOUND = "DECK_NOT_FOUND";
    public static final String ERROR_CODE_FLASHCARD_NOT_FOUND = "FLASHCARD_NOT_FOUND";
    public static final String ERROR_CODE_RESOURCE_NOT_FOUND = "RESOURCE_NOT_FOUND";
    public static final String ERROR_CODE_BUSINESS = "BUSINESS_ERROR";
    public static final String ERROR_CODE_UNAUTHORIZED = "UNAUTHORIZED";
    public static final String ERROR_CODE_INTEGRATION = "INTEGRATION_ERROR";
    public static final String ERROR_CODE_INTERNAL_ERROR = "INTERNAL_ERROR";
    public static final String ERROR_DETAIL_VALIDATION = "VALIDATION";
    public static final String ERROR_DETAIL_INVALID_PAYLOAD = "INVALID_PAYLOAD";
    public static final String ERROR_DETAIL_INTERNAL = "UNEXPECTED_ERROR";
    public static final String ERROR_DETAIL_FIELD_PREFIX = "field=";
}

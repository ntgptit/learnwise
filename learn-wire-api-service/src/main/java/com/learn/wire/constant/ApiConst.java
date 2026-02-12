package com.learn.wire.constant;

public final class ApiConst {

    private ApiConst() {
    }

    public static final String API_BASE_PATH = "/v1";
    public static final String FOLDERS_PATH = API_BASE_PATH + "/folders";
    public static final String FOLDERS_WILDCARD_PATH = FOLDERS_PATH + "/**";
    public static final String FLASHCARDS_PATH = FOLDERS_PATH + "/{folderId}/flashcards";
    public static final String FLASHCARDS_WILDCARD_PATH = API_BASE_PATH + "/folders/*/flashcards/**";
    public static final String FLASHCARDS_ROOT_WILDCARD_PATH = API_BASE_PATH + "/folders/*/flashcards";
    public static final String OPEN_API_TITLE = "Learn Wire API";
    public static final String OPEN_API_VERSION = "v1";
    public static final String OPEN_API_DESCRIPTION = "REST API for Learn Wire backend services.";

    public static final String ERROR_CODE_BAD_REQUEST = "BAD_REQUEST";
    public static final String ERROR_CODE_VALIDATION = "VALIDATION_ERROR";
    public static final String ERROR_CODE_FOLDER_NOT_FOUND = "FOLDER_NOT_FOUND";
    public static final String ERROR_CODE_FLASHCARD_NOT_FOUND = "FLASHCARD_NOT_FOUND";
    public static final String ERROR_CODE_RESOURCE_NOT_FOUND = "RESOURCE_NOT_FOUND";
    public static final String ERROR_CODE_BUSINESS = "BUSINESS_ERROR";
    public static final String ERROR_CODE_INTEGRATION = "INTEGRATION_ERROR";
    public static final String ERROR_CODE_INTERNAL_ERROR = "INTERNAL_ERROR";
    public static final String ERROR_DETAIL_VALIDATION = "VALIDATION";
    public static final String ERROR_DETAIL_INVALID_PAYLOAD = "INVALID_PAYLOAD";
    public static final String ERROR_DETAIL_INTERNAL = "UNEXPECTED_ERROR";
    public static final String ERROR_DETAIL_FIELD_PREFIX = "field=";
}

package com.learn.wire.constant;

public final class LogConst {

    private LogConst() {
    }

    public static final String AUTH_CONTROLLER_REGISTERED_USER_ID = "Registered user id={}";

    public static final String DECK_CONTROLLER_GET_LIST = "Get decks with folderId={}, page={}, size={}";
    public static final String DECK_CONTROLLER_GET_BY_ID = "Get deck by id={} in folderId={}";
    public static final String DECK_CONTROLLER_CREATED = "Created deck with id={} in folderId={}";
    public static final String DECK_CONTROLLER_UPDATED = "Update deck id={} in folderId={}";
    public static final String DECK_CONTROLLER_DELETED = "Delete deck id={} in folderId={}";

    public static final String FLASHCARD_CONTROLLER_GET_LIST = "Get flashcards with deckId={}, page={}, size={}";
    public static final String FLASHCARD_CONTROLLER_CREATED = "Created flashcard with id={} in deckId={}";
    public static final String FLASHCARD_CONTROLLER_UPDATED = "Update flashcard id={} in deckId={}";
    public static final String FLASHCARD_CONTROLLER_DELETED = "Delete flashcard id={} in deckId={}";

    public static final String FOLDER_CONTROLLER_GET_LIST = "Get folders with page={}, size={}, parentFolderId={}";
    public static final String FOLDER_CONTROLLER_GET_BY_ID = "Get folder by id={}";
    public static final String FOLDER_CONTROLLER_CREATED = "Created folder with id={}";
    public static final String FOLDER_CONTROLLER_UPDATED = "Update folder id={}";
    public static final String FOLDER_CONTROLLER_DELETED = "Delete folder id={}";

    public static final String STUDY_CONTROLLER_STARTED = "Started study session id={} for deckId={}";
    public static final String STUDY_CONTROLLER_GET_SESSION = "Get study session id={}";
    public static final String STUDY_CONTROLLER_SUBMIT_EVENT = "Submit study event for sessionId={}";
    public static final String STUDY_CONTROLLER_COMPLETED = "Complete study session id={}";

    public static final String AUTH_SERVICE_REGISTERED_NEW_USER = "Registered new user id={} email={}";
    public static final String DECK_SERVICE_GET_LIST =
            "Get decks with folderId={}, page={}, size={}, sortBy={}, sortDirection={}";
    public static final String DECK_SERVICE_CREATE = "Create deck in folderId={}";
    public static final String DECK_SERVICE_UPDATE = "Update deck id={} in folderId={}";
    public static final String DECK_SERVICE_DELETE = "Delete deck id={} in folderId={}";
    public static final String DECK_SERVICE_DUPLICATE_ACTIVE_NAME =
            "Duplicate active deck name with folderId={} and name={}";

    public static final String FLASHCARD_SERVICE_GET_LIST =
            "Get flashcards with deckId={}, page={}, size={}, sortBy={}, sortDirection={}";
    public static final String FLASHCARD_SERVICE_CREATE = "Create flashcard in deckId={}";
    public static final String FLASHCARD_SERVICE_CREATED = "Created flashcard id={} in deckId={}";
    public static final String FLASHCARD_SERVICE_UPDATE = "Update flashcard id={} in deckId={}";
    public static final String FLASHCARD_SERVICE_DELETE = "Delete flashcard id={} in deckId={}";

    public static final String FOLDER_SERVICE_GET_LIST =
            "Get folders with page={}, size={}, parentFolderId={}, sortBy={}, sortDirection={}";
    public static final String FOLDER_SERVICE_GET_BY_ID = "Get folder id={}";
    public static final String FOLDER_SERVICE_CREATE = "Create folder with parentFolderId={}";
    public static final String FOLDER_SERVICE_CREATED = "Created folder id={}";
    public static final String FOLDER_SERVICE_UPDATE = "Update folder id={} with new parent={}";
    public static final String FOLDER_SERVICE_UPDATED = "Updated folder id={}";
    public static final String FOLDER_SERVICE_DELETE = "Delete folder id={}";
    public static final String FOLDER_SERVICE_SOFT_DELETED = "Soft deleted subtree rootId={} affectedCount={}";

    public static final String STUDY_SERVICE_START_SESSION = "Start study session with deckId={}, mode={}, seed={}";

    public static final String EXCEPTION_VALIDATION_FAILURE = "Validation failure at path {} with detail {}";
    public static final String EXCEPTION_UNREADABLE_PAYLOAD = "Unreadable payload at path {}";
    public static final String EXCEPTION_UNHANDLED_RUNTIME = "Unhandled runtime exception at path {}";
    public static final String EXCEPTION_API_EXCEPTION = "ApiException at path {} with status {} and code {}";
}

package com.learn.wire.constant;

public final class ApiDocConst {

    private ApiDocConst() {
    }

    public static final String TAG_AUTH = "Auth";
    public static final String TAG_DECKS = "Decks";
    public static final String TAG_FLASHCARDS = "Flashcards";
    public static final String TAG_FOLDERS = "Folders";
    public static final String TAG_STUDY_SESSIONS = "Study Sessions";

    public static final String AUTH_OPERATION_REGISTER_USER = "Register user";
    public static final String AUTH_OPERATION_LOGIN_USER = "Login user";
    public static final String AUTH_OPERATION_REFRESH_ACCESS_TOKEN = "Refresh access token";
    public static final String AUTH_OPERATION_GET_CURRENT_USER = "Get current user";
    public static final String AUTH_OPERATION_UPDATE_CURRENT_USER_PROFILE = "Update current user profile";
    public static final String AUTH_OPERATION_UPDATE_CURRENT_USER_SETTINGS = "Update current user settings";

    public static final String DECK_OPERATION_GET_LIST_BY_FOLDER = "Get deck list by folder";
    public static final String DECK_OPERATION_GET_BY_ID = "Get deck by id";
    public static final String DECK_OPERATION_CREATE_IN_FOLDER = "Create deck in folder";
    public static final String DECK_OPERATION_UPDATE = "Update deck";
    public static final String DECK_OPERATION_DELETE = "Delete deck";

    public static final String FLASHCARD_OPERATION_GET_LIST_BY_DECK = "Get flashcard list by deck";
    public static final String FLASHCARD_OPERATION_CREATE_IN_DECK = "Create flashcard in deck";
    public static final String FLASHCARD_OPERATION_UPDATE = "Update flashcard";
    public static final String FLASHCARD_OPERATION_DELETE = "Delete flashcard";

    public static final String FOLDER_OPERATION_GET_LIST = "Get folder list";
    public static final String FOLDER_OPERATION_GET_BY_ID = "Get folder by id";
    public static final String FOLDER_OPERATION_CREATE = "Create folder";
    public static final String FOLDER_OPERATION_UPDATE = "Update folder";
    public static final String FOLDER_OPERATION_DELETE = "Delete folder";

    public static final String STUDY_OPERATION_CREATE_SESSION = "Create study session";
    public static final String STUDY_OPERATION_GET_SESSION = "Get study session";
    public static final String STUDY_OPERATION_SUBMIT_EVENT = "Submit study event";
    public static final String STUDY_OPERATION_COMPLETE_SESSION = "Complete study session";
}

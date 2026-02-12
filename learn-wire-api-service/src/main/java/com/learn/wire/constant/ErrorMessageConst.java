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
}

package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ErrorMessageConst;

public class FlashcardNotFoundException extends ApiException {

    private static final long serialVersionUID = 1L;

    public FlashcardNotFoundException(Long flashcardId) {
        super(
                ApiConst.ERROR_CODE_FLASHCARD_NOT_FOUND,
                HttpStatus.NOT_FOUND,
                ErrorMessageConst.FLASHCARD_ERROR_NOT_FOUND,
                flashcardId);
    }
}

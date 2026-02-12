package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ErrorMessageConst;

public class DeckNotFoundException extends ApiException {

    private static final long serialVersionUID = 1L;

    public DeckNotFoundException(Long deckId) {
        super(
                ApiConst.ERROR_CODE_DECK_NOT_FOUND,
                HttpStatus.NOT_FOUND,
                ErrorMessageConst.DECK_ERROR_NOT_FOUND,
                deckId);
    }
}

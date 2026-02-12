package com.learn.wire.dto.flashcard.request;

import com.learn.wire.constant.FlashcardConst;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record FlashcardCreateRequest(
        @NotBlank(message = FlashcardConst.FRONT_REQUIRED_MESSAGE) @Size(min = FlashcardConst.FRONT_TEXT_MIN_LENGTH, max = FlashcardConst.FRONT_TEXT_MAX_LENGTH, message = FlashcardConst.FRONT_TOO_LONG_MESSAGE) String frontText,

        @NotBlank(message = FlashcardConst.BACK_REQUIRED_MESSAGE) @Size(min = FlashcardConst.BACK_TEXT_MIN_LENGTH, max = FlashcardConst.BACK_TEXT_MAX_LENGTH, message = FlashcardConst.BACK_TOO_LONG_MESSAGE) String backText) {
}

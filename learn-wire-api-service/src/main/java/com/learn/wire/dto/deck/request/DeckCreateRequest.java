package com.learn.wire.dto.deck.request;

import com.learn.wire.constant.DeckConst;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record DeckCreateRequest(
        @NotBlank(message = DeckConst.NAME_IS_REQUIRED_MESSAGE) @Size(min = DeckConst.NAME_MIN_LENGTH, max = DeckConst.NAME_MAX_LENGTH, message = DeckConst.NAME_TOO_LONG_MESSAGE) String name,
        @Size(max = DeckConst.DESCRIPTION_MAX_LENGTH, message = DeckConst.DESCRIPTION_TOO_LONG_MESSAGE) String description) {
}

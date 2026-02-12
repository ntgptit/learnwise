package com.learn.wire.dto.flashcard.request;

import com.learn.wire.constant.FlashcardConst;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class FlashcardListRequest {

    private int page = FlashcardConst.DEFAULT_PAGE;
    private int size = FlashcardConst.DEFAULT_SIZE;
    private String search = "";
    private String sortBy = FlashcardConst.SORT_BY_CREATED_AT;
    private String sortDirection = FlashcardConst.SORT_DIRECTION_DESC;
}

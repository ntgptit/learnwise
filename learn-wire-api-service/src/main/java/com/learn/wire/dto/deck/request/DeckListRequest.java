package com.learn.wire.dto.deck.request;

import com.learn.wire.constant.DeckConst;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class DeckListRequest {

    private int page = DeckConst.DEFAULT_PAGE;
    private int size = DeckConst.DEFAULT_SIZE;
    private String search = "";
    private String sortBy = DeckConst.SORT_BY_CREATED_AT;
    private String sortDirection = DeckConst.SORT_DIRECTION_DESC;
}

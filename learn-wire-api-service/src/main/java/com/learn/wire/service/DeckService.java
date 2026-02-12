package com.learn.wire.service;

import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.deck.query.DeckListQuery;
import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.request.DeckUpdateRequest;
import com.learn.wire.dto.deck.response.DeckResponse;

public interface DeckService {

    PageResponse<DeckResponse> getDecks(DeckListQuery query);

    DeckResponse getDeck(Long folderId, Long deckId);

    DeckResponse createDeck(Long folderId, DeckCreateRequest request);

    DeckResponse updateDeck(Long folderId, Long deckId, DeckUpdateRequest request);

    void deleteDeck(Long folderId, Long deckId);
}

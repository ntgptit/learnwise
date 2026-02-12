package com.learn.wire.service;

import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.flashcard.query.FlashcardListQuery;
import com.learn.wire.dto.flashcard.request.FlashcardCreateRequest;
import com.learn.wire.dto.flashcard.request.FlashcardUpdateRequest;
import com.learn.wire.dto.flashcard.response.FlashcardResponse;

public interface FlashcardService {

    PageResponse<FlashcardResponse> getFlashcards(FlashcardListQuery query);

    FlashcardResponse createFlashcard(Long deckId, FlashcardCreateRequest request);

    FlashcardResponse updateFlashcard(Long deckId, Long flashcardId, FlashcardUpdateRequest request);

    void deleteFlashcard(Long deckId, Long flashcardId);
}

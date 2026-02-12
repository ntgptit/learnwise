package com.learn.wire.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.flashcard.query.FlashcardListQuery;
import com.learn.wire.dto.flashcard.request.FlashcardCreateRequest;
import com.learn.wire.dto.flashcard.request.FlashcardListRequest;
import com.learn.wire.dto.flashcard.request.FlashcardUpdateRequest;
import com.learn.wire.dto.flashcard.response.FlashcardResponse;
import com.learn.wire.service.FlashcardService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@Tag(name = "Flashcards")
@RequestMapping(ApiConst.DECK_FLASHCARDS_PATH)
@Slf4j
@RequiredArgsConstructor
public class FlashcardController {

    private final FlashcardService flashcardService;

    @GetMapping
    @Operation(summary = "Get flashcard list by deck")
    ResponseEntity<PageResponse<FlashcardResponse>> getFlashcards(
            @PathVariable Long deckId,
            @ModelAttribute FlashcardListRequest request) {
        final FlashcardListQuery query = FlashcardListQuery.fromRequest(deckId, request);
        log.debug(
                "Get flashcards with deckId={}, page={}, size={}",
                deckId,
                query.page(),
                query.size());
        return ResponseEntity.ok(this.flashcardService.getFlashcards(query));
    }

    @PostMapping
    @Operation(summary = "Create flashcard in deck")
    ResponseEntity<FlashcardResponse> createFlashcard(
            @PathVariable Long deckId,
            @Valid @RequestBody FlashcardCreateRequest request) {
        final FlashcardResponse response = this.flashcardService.createFlashcard(deckId, request);
        log.info("Created flashcard with id={} in deckId={}", response.id(), deckId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{flashcardId}")
    @Operation(summary = "Update flashcard")
    ResponseEntity<FlashcardResponse> updateFlashcard(
            @PathVariable Long deckId,
            @PathVariable Long flashcardId,
            @Valid @RequestBody FlashcardUpdateRequest request) {
        log.info("Update flashcard id={} in deckId={}", flashcardId, deckId);
        return ResponseEntity.ok(this.flashcardService.updateFlashcard(deckId, flashcardId, request));
    }

    @DeleteMapping("/{flashcardId}")
    @Operation(summary = "Delete flashcard")
    ResponseEntity<Void> deleteFlashcard(@PathVariable Long deckId, @PathVariable Long flashcardId) {
        log.info("Delete flashcard id={} in deckId={}", flashcardId, deckId);
        this.flashcardService.deleteFlashcard(deckId, flashcardId);
        return ResponseEntity.noContent().build();
    }
}

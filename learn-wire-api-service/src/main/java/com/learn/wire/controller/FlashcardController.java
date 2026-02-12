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
@RequestMapping(ApiConst.FLASHCARDS_PATH)
@Slf4j
@RequiredArgsConstructor
public class FlashcardController {

    private final FlashcardService flashcardService;

    @GetMapping
    @Operation(summary = "Get flashcard list by folder")
    ResponseEntity<PageResponse<FlashcardResponse>> getFlashcards(
            @PathVariable Long folderId,
            @ModelAttribute FlashcardListRequest request) {
        final FlashcardListQuery query = FlashcardListQuery.fromRequest(folderId, request);
        log.debug(
                "Get flashcards with folderId={}, page={}, size={}",
                folderId,
                query.page(),
                query.size());
        return ResponseEntity.ok(this.flashcardService.getFlashcards(query));
    }

    @PostMapping
    @Operation(summary = "Create flashcard in folder")
    ResponseEntity<FlashcardResponse> createFlashcard(
            @PathVariable Long folderId,
            @Valid @RequestBody FlashcardCreateRequest request) {
        final FlashcardResponse response = this.flashcardService.createFlashcard(folderId, request);
        log.info("Created flashcard with id={} in folderId={}", response.id(), folderId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{flashcardId}")
    @Operation(summary = "Update flashcard")
    ResponseEntity<FlashcardResponse> updateFlashcard(
            @PathVariable Long folderId,
            @PathVariable Long flashcardId,
            @Valid @RequestBody FlashcardUpdateRequest request) {
        log.info("Update flashcard id={} in folderId={}", flashcardId, folderId);
        return ResponseEntity.ok(this.flashcardService.updateFlashcard(folderId, flashcardId, request));
    }

    @DeleteMapping("/{flashcardId}")
    @Operation(summary = "Delete flashcard")
    ResponseEntity<Void> deleteFlashcard(@PathVariable Long folderId, @PathVariable Long flashcardId) {
        log.info("Delete flashcard id={} in folderId={}", flashcardId, folderId);
        this.flashcardService.deleteFlashcard(folderId, flashcardId);
        return ResponseEntity.noContent().build();
    }
}

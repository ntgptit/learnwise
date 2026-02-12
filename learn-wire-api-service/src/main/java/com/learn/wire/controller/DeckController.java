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
import com.learn.wire.dto.deck.query.DeckListQuery;
import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.request.DeckListRequest;
import com.learn.wire.dto.deck.request.DeckUpdateRequest;
import com.learn.wire.dto.deck.response.DeckResponse;
import com.learn.wire.service.DeckService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@Tag(name = "Decks")
@RequestMapping(ApiConst.DECKS_PATH)
@Slf4j
@RequiredArgsConstructor
public class DeckController {

    private final DeckService deckService;

    @GetMapping
    @Operation(summary = "Get deck list by folder")
    ResponseEntity<PageResponse<DeckResponse>> getDecks(
            @PathVariable Long folderId,
            @ModelAttribute DeckListRequest request) {
        final DeckListQuery query = DeckListQuery.fromRequest(folderId, request);
        log.debug("Get decks with folderId={}, page={}, size={}", folderId, query.page(), query.size());
        return ResponseEntity.ok(this.deckService.getDecks(query));
    }

    @GetMapping("/{deckId}")
    @Operation(summary = "Get deck by id")
    ResponseEntity<DeckResponse> getDeck(@PathVariable Long folderId, @PathVariable Long deckId) {
        log.debug("Get deck by id={} in folderId={}", deckId, folderId);
        return ResponseEntity.ok(this.deckService.getDeck(folderId, deckId));
    }

    @PostMapping
    @Operation(summary = "Create deck in folder")
    ResponseEntity<DeckResponse> createDeck(
            @PathVariable Long folderId,
            @Valid @RequestBody DeckCreateRequest request) {
        final DeckResponse response = this.deckService.createDeck(folderId, request);
        log.info("Created deck with id={} in folderId={}", response.id(), folderId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{deckId}")
    @Operation(summary = "Update deck")
    ResponseEntity<DeckResponse> updateDeck(
            @PathVariable Long folderId,
            @PathVariable Long deckId,
            @Valid @RequestBody DeckUpdateRequest request) {
        log.info("Update deck id={} in folderId={}", deckId, folderId);
        return ResponseEntity.ok(this.deckService.updateDeck(folderId, deckId, request));
    }

    @DeleteMapping("/{deckId}")
    @Operation(summary = "Delete deck")
    ResponseEntity<Void> deleteDeck(@PathVariable Long folderId, @PathVariable Long deckId) {
        log.info("Delete deck id={} in folderId={}", deckId, folderId);
        this.deckService.deleteDeck(folderId, deckId);
        return ResponseEntity.noContent().build();
    }
}

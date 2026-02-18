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
import com.learn.wire.constant.ApiDocConst;
import com.learn.wire.constant.LogConst;
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
@Tag(name = ApiDocConst.TAG_DECKS)
@RequestMapping(ApiConst.DECKS_PATH)
@Slf4j
@RequiredArgsConstructor
public class DeckController {

    private final DeckService deckService;

    @GetMapping
    @Operation(summary = ApiDocConst.DECK_OPERATION_GET_LIST_BY_FOLDER)
    ResponseEntity<PageResponse<DeckResponse>> getDecks(
            @PathVariable Long folderId,
            @ModelAttribute DeckListRequest request) {
        final DeckListQuery query = DeckListQuery.fromRequest(folderId, request);
        log.debug(LogConst.DECK_CONTROLLER_GET_LIST, folderId, query.page(), query.size());
        return ResponseEntity.ok(this.deckService.getDecks(query));
    }

    @GetMapping(ApiConst.DECK_ID_SUB_PATH)
    @Operation(summary = ApiDocConst.DECK_OPERATION_GET_BY_ID)
    ResponseEntity<DeckResponse> getDeck(@PathVariable Long folderId, @PathVariable Long deckId) {
        log.debug(LogConst.DECK_CONTROLLER_GET_BY_ID, deckId, folderId);
        return ResponseEntity.ok(this.deckService.getDeck(folderId, deckId));
    }

    @PostMapping
    @Operation(summary = ApiDocConst.DECK_OPERATION_CREATE_IN_FOLDER)
    ResponseEntity<DeckResponse> createDeck(
            @PathVariable Long folderId,
            @Valid @RequestBody DeckCreateRequest request) {
        final DeckResponse response = this.deckService.createDeck(folderId, request);
        log.info(LogConst.DECK_CONTROLLER_CREATED, response.id(), folderId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping(ApiConst.DECK_ID_SUB_PATH)
    @Operation(summary = ApiDocConst.DECK_OPERATION_UPDATE)
    ResponseEntity<DeckResponse> updateDeck(
            @PathVariable Long folderId,
            @PathVariable Long deckId,
            @Valid @RequestBody DeckUpdateRequest request) {
        log.info(LogConst.DECK_CONTROLLER_UPDATED, deckId, folderId);
        return ResponseEntity.ok(this.deckService.updateDeck(folderId, deckId, request));
    }

    @DeleteMapping(ApiConst.DECK_ID_SUB_PATH)
    @Operation(summary = ApiDocConst.DECK_OPERATION_DELETE)
    ResponseEntity<Void> deleteDeck(@PathVariable Long folderId, @PathVariable Long deckId) {
        log.info(LogConst.DECK_CONTROLLER_DELETED, deckId, folderId);
        this.deckService.deleteDeck(folderId, deckId);
        return ResponseEntity.noContent().build();
    }
}

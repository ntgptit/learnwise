package com.learn.wire.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.dto.deck.request.DeckAudioSettingsUpdateRequest;
import com.learn.wire.dto.deck.response.DeckAudioSettingsResponse;
import com.learn.wire.service.DeckService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping(ApiConst.API_BASE_PATH + "/decks")
@RequiredArgsConstructor
public class DeckAudioSettingsController {

    private final DeckService deckService;

    @GetMapping("/{deckId}/settings")
    ResponseEntity<DeckAudioSettingsResponse> getDeckAudioSettings(@PathVariable Long deckId) {
        return ResponseEntity.ok(this.deckService.getDeckAudioSettings(deckId));
    }

    @PatchMapping("/{deckId}/settings")
    ResponseEntity<DeckAudioSettingsResponse> updateDeckAudioSettings(
            @PathVariable Long deckId,
            @RequestBody DeckAudioSettingsUpdateRequest request) {
        return ResponseEntity.ok(this.deckService.updateDeckAudioSettings(deckId, request));
    }
}

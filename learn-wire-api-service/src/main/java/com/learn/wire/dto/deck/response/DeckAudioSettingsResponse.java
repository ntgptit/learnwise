package com.learn.wire.dto.deck.response;

public record DeckAudioSettingsResponse(
        Long deckId,
        Boolean autoPlayAudioOverride,
        Integer cardsPerSessionOverride,
        String ttsVoiceIdOverride,
        Double ttsSpeechRateOverride,
        Double ttsPitchOverride,
        Double ttsVolumeOverride,
        Boolean autoPlayAudio,
        Integer cardsPerSession,
        String ttsVoiceId,
        Double ttsSpeechRate,
        Double ttsPitch,
        Double ttsVolume) {
}

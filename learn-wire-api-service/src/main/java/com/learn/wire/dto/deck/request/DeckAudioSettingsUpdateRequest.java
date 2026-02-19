package com.learn.wire.dto.deck.request;

public record DeckAudioSettingsUpdateRequest(
        Boolean autoPlayAudioOverride,
        Integer cardsPerSessionOverride,
        String ttsVoiceIdOverride,
        Double ttsSpeechRateOverride,
        Double ttsPitchOverride,
        Double ttsVolumeOverride) {
}

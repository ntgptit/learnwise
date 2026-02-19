package com.learn.wire.dto.auth.request;

import com.learn.wire.constant.AuthConst;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AuthUpdateSettingsRequest(
        @NotBlank(message = AuthConst.THEME_MODE_REQUIRED_MESSAGE) String themeMode,
        @NotNull(message = AuthConst.STUDY_AUTO_PLAY_AUDIO_REQUIRED_MESSAGE) Boolean studyAutoPlayAudio,
        @NotNull(message = AuthConst.STUDY_CARDS_PER_SESSION_REQUIRED_MESSAGE)
        @Min(value = AuthConst.STUDY_CARDS_PER_SESSION_MIN, message = AuthConst.STUDY_CARDS_PER_SESSION_MIN_MESSAGE)
        @Max(value = AuthConst.STUDY_CARDS_PER_SESSION_MAX, message = AuthConst.STUDY_CARDS_PER_SESSION_MAX_MESSAGE) Integer studyCardsPerSession,
        String ttsVoiceId,
        @NotNull Double ttsSpeechRate,
        @NotNull Double ttsPitch,
        @NotNull Double ttsVolume) {
}

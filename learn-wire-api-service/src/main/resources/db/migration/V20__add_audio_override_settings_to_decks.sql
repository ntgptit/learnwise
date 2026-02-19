ALTER TABLE decks
ADD COLUMN setting_auto_play_audio_override BOOLEAN,
ADD COLUMN setting_cards_per_session_override INTEGER,
ADD COLUMN setting_tts_voice_id_override VARCHAR(255),
ADD COLUMN setting_tts_speech_rate_override DOUBLE PRECISION,
ADD COLUMN setting_tts_pitch_override DOUBLE PRECISION,
ADD COLUMN setting_tts_volume_override DOUBLE PRECISION;

ALTER TABLE decks
ADD CONSTRAINT chk_decks_setting_cards_per_session_override
CHECK (
    setting_cards_per_session_override IS NULL
    OR setting_cards_per_session_override BETWEEN 5 AND 20
);

ALTER TABLE decks
ADD CONSTRAINT chk_decks_setting_tts_speech_rate_override
CHECK (
    setting_tts_speech_rate_override IS NULL
    OR setting_tts_speech_rate_override BETWEEN 0.2 AND 1.0
);

ALTER TABLE decks
ADD CONSTRAINT chk_decks_setting_tts_pitch_override
CHECK (
    setting_tts_pitch_override IS NULL
    OR setting_tts_pitch_override BETWEEN 0.5 AND 2.0
);

ALTER TABLE decks
ADD CONSTRAINT chk_decks_setting_tts_volume_override
CHECK (
    setting_tts_volume_override IS NULL
    OR setting_tts_volume_override BETWEEN 0.0 AND 1.0
);

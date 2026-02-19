ALTER TABLE user_settings
ADD COLUMN tts_voice_id VARCHAR(255),
ADD COLUMN tts_speech_rate DOUBLE PRECISION NOT NULL DEFAULT 0.48,
ADD COLUMN tts_pitch DOUBLE PRECISION NOT NULL DEFAULT 1.0,
ADD COLUMN tts_volume DOUBLE PRECISION NOT NULL DEFAULT 1.0;

ALTER TABLE user_settings
ADD CONSTRAINT chk_user_settings_tts_speech_rate
CHECK (tts_speech_rate BETWEEN 0.2 AND 1.0);

ALTER TABLE user_settings
ADD CONSTRAINT chk_user_settings_tts_pitch
CHECK (tts_pitch BETWEEN 0.5 AND 2.0);

ALTER TABLE user_settings
ADD CONSTRAINT chk_user_settings_tts_volume
CHECK (tts_volume BETWEEN 0.0 AND 1.0);

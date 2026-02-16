ALTER TABLE app_users
ADD COLUMN theme_mode VARCHAR(16) NOT NULL DEFAULT 'SYSTEM';

ALTER TABLE app_users
ADD COLUMN study_auto_play_audio BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE app_users
ADD COLUMN study_cards_per_session INTEGER NOT NULL DEFAULT 10;

ALTER TABLE app_users
ADD CONSTRAINT chk_app_users_theme_mode
CHECK (theme_mode IN ('SYSTEM', 'LIGHT', 'DARK'));

ALTER TABLE app_users
ADD CONSTRAINT chk_app_users_study_cards_per_session
CHECK (study_cards_per_session BETWEEN 5 AND 50);

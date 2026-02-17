UPDATE app_users
SET study_cards_per_session = 20
WHERE study_cards_per_session > 20;

ALTER TABLE app_users
DROP CONSTRAINT chk_app_users_study_cards_per_session;

ALTER TABLE app_users
ADD CONSTRAINT chk_app_users_study_cards_per_session
CHECK (study_cards_per_session BETWEEN 5 AND 20);

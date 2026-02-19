ALTER TABLE app_users
ADD COLUMN username VARCHAR(120);

ALTER TABLE app_users
ADD COLUMN normalized_username VARCHAR(120);

ALTER TABLE app_users
ADD CONSTRAINT chk_app_users_username_not_blank
CHECK (username IS NULL OR TRIM(username) <> '');

ALTER TABLE app_users
ADD CONSTRAINT chk_app_users_normalized_username_not_blank
CHECK (normalized_username IS NULL OR TRIM(normalized_username) <> '');

CREATE UNIQUE INDEX uq_app_users_normalized_username
ON app_users (normalized_username)
WHERE normalized_username IS NOT NULL;


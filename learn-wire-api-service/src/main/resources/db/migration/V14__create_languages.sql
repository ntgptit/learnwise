CREATE TABLE languages (
    code        VARCHAR(10)  PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    native_name VARCHAR(100) NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE
);

INSERT INTO languages (code, name, native_name, sort_order) VALUES
    ('en', 'English',    'English',      1),
    ('vi', 'Vietnamese', 'Tiếng Việt',   2),
    ('ko', 'Korean',     '한국어',        3),
    ('ja', 'Japanese',   '日本語',        4);

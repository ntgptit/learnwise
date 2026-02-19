ALTER TABLE flashcards ADD COLUMN front_lang_code VARCHAR(10);
ALTER TABLE flashcards ADD COLUMN back_lang_code  VARCHAR(10);

ALTER TABLE flashcards ADD CONSTRAINT fk_flashcards_front_lang
    FOREIGN KEY (front_lang_code) REFERENCES languages(code);

ALTER TABLE flashcards ADD CONSTRAINT fk_flashcards_back_lang
    FOREIGN KEY (back_lang_code) REFERENCES languages(code);

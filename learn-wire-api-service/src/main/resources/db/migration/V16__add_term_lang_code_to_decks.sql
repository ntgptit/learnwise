ALTER TABLE decks ADD COLUMN term_lang_code VARCHAR(10);

ALTER TABLE decks ADD CONSTRAINT fk_decks_term_lang
    FOREIGN KEY (term_lang_code) REFERENCES languages(code);

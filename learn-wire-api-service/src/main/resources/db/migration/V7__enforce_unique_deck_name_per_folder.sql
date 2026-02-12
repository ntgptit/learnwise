ALTER TABLE decks
ADD COLUMN normalized_name VARCHAR(120);

UPDATE decks
SET name = TRIM(name)
WHERE name <> TRIM(name);

UPDATE decks
SET normalized_name = LOWER(TRIM(name))
WHERE deleted_at IS NULL;

UPDATE decks deck
SET
    name = CONCAT(TRIM(deck.name), ' #', deck.id),
    normalized_name = LOWER(CONCAT(TRIM(deck.name), ' #', deck.id))
WHERE deck.deleted_at IS NULL
  AND EXISTS (
      SELECT 1
      FROM decks other
      WHERE other.deleted_at IS NULL
        AND other.folder_id = deck.folder_id
        AND other.normalized_name = deck.normalized_name
        AND other.id < deck.id
  );

UPDATE decks
SET normalized_name = NULL
WHERE deleted_at IS NOT NULL;

CREATE UNIQUE INDEX uq_decks_folder_active_normalized_name
ON decks (folder_id, normalized_name);

ALTER TABLE decks
ADD CONSTRAINT chk_decks_active_normalized_name
CHECK (deleted_at IS NOT NULL OR normalized_name IS NOT NULL);

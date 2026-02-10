ALTER TABLE folders
ADD COLUMN parent_folder_id BIGINT;

ALTER TABLE folders
ADD COLUMN direct_flashcard_count INT NOT NULL DEFAULT 0;

ALTER TABLE folders
ADD CONSTRAINT fk_folders_parent
FOREIGN KEY (parent_folder_id) REFERENCES folders (id);

CREATE INDEX idx_folders_parent_folder_id ON folders (parent_folder_id);

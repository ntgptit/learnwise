INSERT INTO folders (
    id,
    name,
    description,
    color_hex,
    parent_folder_id,
    direct_flashcard_count,
    aggregate_flashcard_count,
    created_by,
    updated_by
)
SELECT
    1001,
    'Sample Root',
    'Sample root folder seeded by Flyway.',
    '#2563EB',
    NULL,
    8,
    13,
    'flyway',
    'flyway'
WHERE '${seed_demo_data}' = 'true'
  AND NOT EXISTS (
      SELECT 1
      FROM folders
      WHERE id = 1001
  );

INSERT INTO folders (
    id,
    name,
    description,
    color_hex,
    parent_folder_id,
    direct_flashcard_count,
    aggregate_flashcard_count,
    created_by,
    updated_by
)
SELECT
    1002,
    'Sample Child',
    'Sample child folder seeded by Flyway.',
    '#10B981',
    1001,
    5,
    5,
    'flyway',
    'flyway'
WHERE '${seed_demo_data}' = 'true'
  AND EXISTS (
      SELECT 1
      FROM folders
      WHERE id = 1001
  )
  AND NOT EXISTS (
      SELECT 1
      FROM folders
      WHERE id = 1002
  );

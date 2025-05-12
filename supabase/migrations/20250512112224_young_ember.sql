/*
  # Add resident status to devotees table

  1. Changes
    - Add `is_resident` boolean column to `devotees` table with default value of true
    - Update existing rows to set `is_resident` to true

  2. Notes
    - Uses safe migration pattern with IF NOT EXISTS check
    - Sets default value for new rows
    - Updates existing rows to maintain data consistency
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'devotees' AND column_name = 'is_resident'
  ) THEN
    ALTER TABLE devotees ADD COLUMN is_resident boolean DEFAULT true NOT NULL;
  END IF;
END $$;
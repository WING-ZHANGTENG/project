-- Add the WCS pallet split completion flag.
-- 0: not completed; 1: completed.

SET @schema_name = DATABASE();

SELECT IF(
    EXISTS(
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = @schema_name
          AND TABLE_NAME = 'pallet_split'
          AND COLUMN_NAME = 'split_flag'
    ),
    'SELECT ''skip pallet_split.split_flag''',
    'ALTER TABLE pallet_split ADD COLUMN split_flag varchar(1) NOT NULL DEFAULT ''0'' COMMENT ''0-not completed, 1-completed'' AFTER sync_flag'
) INTO @ddl;
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE pallet_split
SET split_flag = '0'
WHERE split_flag IS NULL OR split_flag = '';

ALTER TABLE pallet_split
    MODIFY COLUMN split_flag varchar(1) NOT NULL DEFAULT '0' COMMENT '0-not completed, 1-completed';

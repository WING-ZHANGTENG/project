-- Add an update timestamp to item_info and initialize existing records from create_time.

SET @sql = IF(
    EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'item_info'
          AND COLUMN_NAME = 'update_time'
    ),
    'SELECT ''item_info.update_time already exists'' AS message',
    'ALTER TABLE item_info ADD COLUMN update_time VARCHAR(32) NULL COMMENT ''修改时间'' AFTER create_time'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE item_info
SET update_time = create_time
WHERE update_time IS NULL;
